# -*- coding: utf-8 -*-
"""
utilities to help disassemble pokémon crystal
"""

import os
import sys
import inspect
import hashlib
import json
from copy import copy, deepcopy
import subprocess
from new import classobj
import random
import logging

# for capwords
import string

# for python2.6
if not hasattr(json, "dumps"):
    json.dumps = json.write

spacing = "\t"

lousy_dragon_shrine_hack = [0x18d079, 0x18d0a9, 0x18d061, 0x18d091]

# table of pointers to map groups
# each map group contains some number of map headers
map_group_pointer_table = 0x94000
map_group_count = 26
map_group_offsets = []
map_header_byte_size = 9
second_map_header_byte_size = 12

# event segment sizes
warp_byte_size = 5
trigger_byte_size = 8
signpost_byte_size = 5
people_event_byte_size = 13

max_texts = 3
text_count = 0
texts = []

# these appear outside of quotes (see pokered/extras/pretty_map_headers.py)
# this doesn't do anything but is still used in TextScript
constant_abbreviation_bytes = {}

import helpers
import chars
import labels
import pksv
import romstr
import pointers
import interval_map
import trainers
import move_constants
import pokemon_constants
import item_constants
import wram
import exceptions

import addresses
is_valid_address = addresses.is_valid_address

import old_text_script
OldTextScript = old_text_script

import configuration
conf = configuration.Config()

data_path = os.path.join(os.path.abspath(os.path.dirname(__file__)), "data/pokecrystal/")
conf.wram = os.path.join(data_path, "wram.asm")
conf.gbhw = os.path.join(data_path, "gbhw.asm")
conf.hram = os.path.join(data_path, "hram.asm")

from map_names import map_names
from song_names import song_names

# ---- script_parse_table explanation ----
# This is an IntervalMap that keeps track of previously parsed scripts, texts
# and other objects. Anything that has a location in the ROM should be mapped
# to an interval (a range of addresses) in this structure. Each object that is
# assigned to an interval should implement attributes or methods like:
#   ATTRIBUTE/METHOD            EXPLANATION
#   label                       what the heck to call the object
#   address                     where it begins
#   to_asm()                    spit out asm (not including label)
# keys are intervals "500..555" of byte addresses for each script
# last byte is not inclusive(?) really? according to who??
# this is how to make sure scripts are not recalculated
script_parse_table = interval_map.IntervalMap()

def is_script_already_parsed_at(address):
    """looks up whether or not a script is parsed at a certain address"""
    if script_parse_table[address] == None:
        return False
    return True

def script_parse_table_pretty_printer():
    """helpful debugging output"""
    for each in script_parse_table.items():
        logging.info("{0}".format(each))

def map_name_cleaner(input):
    """generate a valid asm label for a given map name"""
    return input.replace(":", "").\
                 replace("(", "").\
                 replace(")", "").\
                 replace("'", "").\
                 replace("/", "").\
                 replace(",", "").\
                 replace(".", "").\
                 replace("Pokémon Center", "PokeCenter").\
                 replace("é", "e").\
                 replace("-", "").\
                 replace("Hooh", "HoOh").\
                 replace("hooh", "HoOh").\
                 replace(" ", "")

rom = romstr.RomStr(None)

def direct_load_rom(filename=None):
    """loads bytes into memory"""
    if filename == None:
        filename = os.path.join(conf.path, "baserom.gbc")
    global rom
    file_handler = open(filename, "rb")
    rom = romstr.RomStr(file_handler.read())
    file_handler.close()
    return rom

def load_rom(filename=None):
    """checks that the loaded rom matches the path
    and then loads the rom if necessary."""
    if filename == None:
        filename = os.path.join(conf.path, "baserom.gbc")
    global rom
    if rom != romstr.RomStr(None) and rom != None:
        return rom
    if not isinstance(rom, romstr.RomStr):
        return direct_load_rom(filename=filename)
    elif os.lstat(filename).st_size != len(rom):
        return direct_load_rom(filename)

def direct_load_asm(filename=None):
    if filename == None:
        filename = os.path.join(conf.path, "main.asm")
    """returns asm source code (AsmList) from a file"""
    asm = open(filename, "r").read().split("\n")
    asm = romstr.AsmList(asm)
    return asm

def load_asm(filename=None):
    """returns asm source code (AsmList) from a file (uses a global)"""
    if filename == None:
        filename = os.path.join(conf.path, "main.asm")
    global asm
    asm = direct_load_asm(filename=filename)
    return asm

def load_asm2(filename="../main.asm"):
    """loads the asm source code into memory"""
    new_asm = Asm(filename=filename)
    return new_asm

def rom_interval(offset, length, rom=None, strings=True, debug=True):
    """returns hex values for the rom starting at offset until offset+length"""
    return rom.interval(offset, length, strings=strings, debug=debug)

def rom_until(offset, byte, rom=None, strings=True, debug=True):
    """returns hex values from rom starting at offset until the given byte"""
    return rom.until(offset, byte, strings=strings, debug=debug)

def how_many_until(byte, starting, rom):
    index = rom.find(byte, starting)
    return index - starting

def load_map_group_offsets(map_group_pointer_table, map_group_count, rom=None):
    """reads the map group table for the list of pointers"""
    map_group_offsets = [] # otherwise this method can only be used once
    data = rom.interval(map_group_pointer_table, map_group_count*2, strings=False)
    data = helpers.grouper(data)
    for pointer_parts in data:
        pointer = pointer_parts[0] + (pointer_parts[1] << 8)
        offset = pointer - 0x4000 + map_group_pointer_table
        map_group_offsets.append(offset)
    return map_group_offsets

def calculate_pointer_from_bytes_at(address, bank=False):
    """calculates a pointer from 2 bytes at a location
    or 3-byte pointer [bank][2-byte pointer] if bank=True"""
    if bank == True:
        bank = ord(rom[address])
        address += 1
    elif bank == False or bank == None:
        bank = pointers.calculate_bank(address)
    elif bank == "reverse" or bank == "reversed":
        bank = ord(rom[address+2])
    elif type(bank) == int:
        pass
    else:
        raise Exception("bad bank given to calculate_pointer_from_bytes_at")
    byte1 = ord(rom[address])
    byte2 = ord(rom[address+1])
    temp  = byte1 + (byte2 << 8)
    if temp == 0:
        return None
    return pointers.calculate_pointer(temp, bank)

def clean_up_long_info(long_info):
    """cleans up some data from parse_script_engine_script_at formatting issues"""
    long_info = str(long_info)
    # get rid of the first newline
    if long_info[0] == "\n":
        long_info = long_info[1:]
    # get rid of the last newline and any leftover space
    if long_info.count("\n") > 0:
        if long_info[long_info.rindex("\n")+1:].isspace():
            long_info = long_info[:long_info.rindex("\n")]
        # remove spaces+hash from the front of each line
        new_lines = []
        for line in long_info.split("\n"):
            line = line.strip()
            if line[0] == "#":
                line = line[1:]
            new_lines.append(line)
        long_info = "\n".join(new_lines)
    return long_info

def get_pokemon_constant_by_id(id):
    if id == 0:
        return None
    else:
        return pokemon_constants.pokemon_constants[id]

def command_debug_information(command_byte=None, map_group=None, map_id=None, address=0, info=None, long_info=None, pksv_name=None):
    "used to help debug in parse_script_engine_script_at"
    info1 = "parsing command byte " + hex(command_byte) + " for map " + \
          str(map_group) + "." + str(map_id) + " at " + hex(address)
    info1 += "    pksv: " + str(pksv_name)
    #info1 += "    info: " + str(info)
    #info1 += "    long_info: " + long_info
    return info1

all_texts = []
class TextScript:
    """
    A text is a sequence of bytes (and sometimes commands). It's not the same
    thing as a Script. The bytes are translated into characters based on the
    lookup table (see chars.py). The in-text commands are for including values
    from RAM, playing sound, etc.

    see: http://hax.iimarck.us/files/scriptingcodes_eng.htm#InText
    """
    base_label = "UnknownText_"
    def __init__(self, address, map_group=None, map_id=None, debug=False, label=None, force=False, show=None, script_parse_table=None, text_command_classes=None):
        self.text_command_classes = text_command_classes
        self.script_parse_table = script_parse_table

        self.address = address
        # $91, $84, $82, $54, $8c
        # 0x19768c is a a weird problem?
        if address in [0x26ef, 0x26f2, 0x6ee, 0x1071, 0x5ce33, 0x69523, 0x7ee98, 0x72176, 0x7a578, 0x19c09b, 0x19768c]:
            return None
        self.map_group, self.map_id, self.debug = map_group, map_id, debug
        self.dependencies = None
        self.commands = None
        self.force = force

        if is_script_already_parsed_at(address) and not force:
            raise Exception("TextScript already parsed at "+hex(address))

        if not label:
            label = self.base_label + hex(address)
        self.label = Label(name=label, address=address, object=self)

        self.parse()

    def is_valid(self):
        return not (self.address in [0x26ef, 0x26f2, 0x6ee, 0x1071, 0x5ce33, 0x69523, 0x7ee98, 0x72176, 0x7a578, 0x19c09b, 0x19768c])

    # hmm this looks exactly like Script.get_dependencies (which makes sense..)
    def get_dependencies(self, recompute=False, global_dependencies=set()):
        if self.address in [0x26ef, 0x26f2, 0x6ee, 0x1071, 0x5ce33, 0x69523, 0x7ee98, 0x72176, 0x7a578, 0x19c09b, 0x19768c]:
            return []

        if self.dependencies != None and not recompute:
            global_dependencies.update(self.dependencies)
            return self.dependencies

        dependencies = []

        for command in self.commands:
            deps = command.get_dependencies(recompute=recompute, global_dependencies=global_dependencies)
            dependencies.extend(deps)

        self.dependencies = dependencies
        return self.dependencies

    # this is almost an exact copy of Script.parse
    # with the exception of using text_command_classes instead of command_classes
    def parse(self):
        if self.address in [0x26ef, 0x26f2, 0x6ee, 0x1071, 0x5ce33, 0x69523, 0x7ee98, 0x72176, 0x7a578, 0x19c09b, 0x19768c]:
            return None

        text_command_classes = self.text_command_classes
        script_parse_table = self.script_parse_table
        current_address = copy(self.address)
        start_address = copy(current_address)

        # don't clutter up my screen
        if self.debug:
            logging.debug(
                "NewTextScript.parse address={address} map_group={map_group} map_id={map_id}"
                .format(
                    address=hex(self.address),
                    map_group=str(self.map_group),
                    map_id=self.map_id,
                )
            )

        # load up the rom if it hasn't been loaded already
        rom = load_rom()

        # in the event that the script parsing fails.. it would be nice to leave evidence
        script_parse_table[start_address:start_address+1] = "incomplete NewTextScript.parse"

        # start with a blank script
        commands = []

        # use this to control the while loop
        end = False

        # for each command found...
        while not end:
            # get the current scripting byte
            cur_byte = ord(rom[current_address])

            # reset the command class (last command was probably different)
            scripting_command_class = None

            # match the command id byte to a scripting command class like MainText
            for class_ in text_command_classes:
                if class_[1].id == cur_byte:
                    scripting_command_class = class_[1]

            if self.address == 0x9c00e and self.debug:
                if current_address > 0x9c087:
                    logging.debug("self.commands is: {commands}".format(commands=commands))
                    for num in [0, 1]:
                        logging.debug(
                            "command {id} address={address} last_address={last}"
                            .format(
                                id=str(num),
                                address=hex(commands[num].address),
                                last=hex(commands[num].last_address),
                            )
                        )
                    raise Exception("going beyond the bounds for this text script")

            # no matching command found
            if scripting_command_class == None:
                raise Exception("unable to parse text command $%.2x in the text script at %s at %s" % (cur_byte, hex(start_address), hex(current_address)))

            # create an instance of the command class and let it parse its parameter bytes
            cls = scripting_command_class(address=current_address, map_group=self.map_group, map_id=self.map_id, debug=self.debug, force=self.force)

            if self.debug:
                logging.debug(cls.to_asm())

            # store it in this script object
            commands.append(cls)

            # certain commands will end the scripting engine
            end = cls.end

            # skip past the command's parameter bytes to go to the next command
            #current_address += cls.size
            current_address = cls.last_address

        # last byte belonging to script is last byte of last command,
        # or the last byte of the last command's last parameter
        # (actually i think this might be the next byte after??)
        self.last_address = current_address

        if self.debug:
            logging.debug("cls.address is {0}".format(hex(cls.address)))
            logging.debug("cls.size is {0}".format(hex(cls.size)))
            logging.debug("cls.last_address is {0}".format(hex(cls.last_address)))
            logging.debug("self.last_address is {0}".format(hex(self.last_address)))

        if self.last_address != (cls.address + cls.size):
            raise exceptions.TextScriptException(
                "the last address should equal the last command's (address + size)"
            )

        if self.last_address != cls.last_address:
            raise exceptions.TextScriptException(
                "the last address of the TextScript should be the last_address of its last command"
            )

        # just some debugging..
        if self.debug:
            last_address = self.last_address
            logging.debug("TextScript last_address == {0}".format(hex(last_address)))
            #assert last_address != 0x5db06, "TextScript.parse somehow has a text with a last_address of 0x5db06 instead of 0x5db07"

        # store the script in the global table/map thing
        script_parse_table[start_address:current_address] = self
        all_texts.append(self)

        if self.debug:
            asm_output = "\n".join([command.to_asm() for command in commands])
            logging.debug("asm_output is:\n{0}".format(asm_output))

        # store the script
        self.commands = commands

        return commands

    def to_asm(self):
        if self.address in [0x26ef, 0x26f2, 0x6ee, 0x1071, 0x5ce33, 0x69523, 0x7ee98, 0x72176, 0x7a578, 0x19c09b, 0x19768c]:
            return None

        asm_output = "\n".join([command.to_asm() for command in self.commands])
        return asm_output

def parse_text_engine_script_at(address, map_group=None, map_id=None, debug=True, show=True, force=False):
    """parses a text-engine script ("in-text scripts")
    http://hax.iimarck.us/files/scriptingcodes_eng.htm#InText
    see parse_text_at2, parse_text_at, and process_00_subcommands
    """
    if is_script_already_parsed_at(address) and not force:
        return script_parse_table[address]
    return TextScript(address, map_group=map_group, map_id=map_id, debug=debug, show=show, force=force, script_parse_table=script_parse_table, text_command_classes=text_command_classes)

def find_text_addresses():
    """returns a list of text pointers
    useful for testing parse_text_engine_script_at"""
    return TextScript.find_addresses()

class EncodedText:
    """a sequence of bytes that, when decoded, represent readable text
    based on the chars table from preprocessor.py and other places"""
    base_label = "UnknownRawText_"

    def __init__(self, address, bank=None, map_group=None, map_id=None, debug=True, label=None):
        self.address = address
        if bank:
            self.bank = bank
        else:
            self.bank = pointers.calculate_bank(address)
        self.map_group, self.map_id, self.debug = map_group, map_id, debug
        if not label:
            label = self.base_label + hex(address)
        self.label = Label(name=label, address=address, object=self)
        self.dependencies = None
        self.parse()
        script_parse_table[self.address : self.last_address] = self

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        return []

    def parse(self):
        offset = self.address

        # read until $57, $50 or $58
        jump57 = how_many_until(chr(0x57), offset, rom)
        jump50 = how_many_until(chr(0x50), offset, rom)
        jump58 = how_many_until(chr(0x58), offset, rom)

        # whichever command comes first
        jump = min([jump57, jump50, jump58])

        end_address = offset + jump # we want the address before $57

        text = parse_text_at2(offset, end_address-offset, debug=self.debug)

        if jump == jump50:
            text += "@"

        self.text = text

        self.last_address = self.end_address = end_address

    def to_asm(self):
        return "\""+self.text+"\""

    @staticmethod
    def process_00_subcommands(start_address, end_address, debug=True):
        """split this text up into multiple lines
        based on subcommands ending each line"""
        if debug:
            logging.debug(
                "process_00_subcommands({start}, {end})"
                .format(
                    start=hex(start_address),
                    end=hex(end_address),
                )
            )
        lines = {}
        subsection = rom[start_address:end_address]

        line_count = 0
        current_line = []
        for pbyte in subsection:
            byte = ord(pbyte)
            current_line.append(byte)
            if  byte == 0x4f or byte == 0x51 or byte == 0x55:
                lines[line_count] = current_line
                current_line = []
                line_count += 1

        # don't forget the last line
        lines[line_count] = current_line
        line_count += 1
        return lines

    @staticmethod
    def from_bytes(bytes, debug=True, japanese=False):
        """assembles a string based on bytes looked up in the chars table"""
        line = ""
        if japanese: charset = chars.jap_chars
        else: charset = chars.chars
        for byte in bytes:
            if type(byte) != int:
                byte = ord(byte)
            if byte in charset.keys():
                line += charset[byte]
            elif debug:
                logging.debug("byte not known: {0}".format(hex(byte)))
        return line

    @staticmethod
    def parse_text_at(address, count=10, debug=True, japanese=False):
        """returns a string of text from an address
        this does not handle text commands"""
        output = ""
        commands = process_00_subcommands(address, address+count, debug=debug)
        for (line_id, line) in commands.items():
            output += parse_text_from_bytes(line, debug=debug, japanese=japanese)
        texts.append([address, output])
        return output


def process_00_subcommands(start_address, end_address, debug=True):
    """split this text up into multiple lines
    based on subcommands ending each line"""
    return EncodedText.process_00_subcommands(start_address, end_address, debug=debug)

def parse_text_from_bytes(bytes, debug=True, japanese=False):
    """assembles a string based on bytes looked up in the chars table"""
    return EncodedText.from_bytes(bytes, debug=debug, japanese=japanese)

def parse_text_at(address, count=10, debug=True):
    """returns a list of bytes from an address
    see parse_text_at2 for pretty printing"""
    return parse_text_from_bytes(rom.interval(address, count, strings=False), debug=debug)

def parse_text_at2(address, count=10, debug=True, japanese=False):
    """returns a string of text from an address
    this does not handle text commands"""
    return EncodedText.parse_text_at(address, count, debug=debug, japanese=japanese)

def parse_text_at3(address, map_group=None, map_id=None, debug=False):
    deh = script_parse_table[address]
    if deh:
        return deh
    else:
        text = TextScript(address, map_group=map_group, map_id=map_id, debug=debug, script_parse_table=script_parse_table, text_command_classes=text_command_classes)
        if text.is_valid():
            return text
        else:
            return None

def rom_text_at(address, count=10):
    """prints out raw text from the ROM
    like for 0x112110"""
    return "".join([chr(x) for x in rom.interval(address, count, strings=False)])

def get_map_constant_label(map_group=None, map_id=None, map_internal_ids=None):
    """returns PALLET_TOWN for some map group/id pair"""
    if map_group == None:
        raise Exception("need map_group")
    if map_id == None:
        raise Exception("need map_id")

    for (id, each) in map_internal_ids.items():
        if each["map_group"] == map_group and each["map_id"] == map_id:
            return each["label"]
    return None

def get_map_constant_label_by_id(global_id, map_internal_ids):
    """returns a map constant label for a particular map id"""
    return map_internal_ids[global_id]["label"]

def get_id_for_map_constant_label(label):
    """returns some global id for a given map constant label
    PALLET_TOWN = 1, for instance."""
    global map_internal_ids
    for (id, each) in map_internal_ids.items():
        if each["label"] == label:
            return id
    return None

def generate_map_constant_labels():
    """generates the global for this script
    mapping ids to map groups/ids/labels"""
    global map_internal_ids
    map_internal_ids = {}
    i = 0
    for map_group in map_names.keys():
        for map_id in map_names[map_group].keys():
            if map_id == "offset": continue
            cmap = map_names[map_group][map_id]
            name = cmap["name"]
            name = name.replace("Pokémon Center", "PokeCenter").\
                        replace(" ", "_").\
                        replace("-", "_").\
                        replace("é", "e")
            constant_label = map_name_cleaner(name).upper()
            map_internal_ids[i] = {"label": constant_label,
                                   "map_id": map_id,
                                   "map_group": map_group}
            i += 1
    return map_internal_ids

# see generate_map_constant_labels() later
def generate_map_constants():
    """generates content for constants.asm
    this will generate two macros: GROUP and MAP"""
    global map_internal_ids
    if map_internal_ids == None or map_internal_ids == {}:
        generate_map_constant_labels()
    globals, groups, maps = "", "", ""
    for (id, each) in map_internal_ids.items():
        label = each["label"].replace("-", "_").replace("é", "e").upper()

        groups += "GROUP_"+ label + " EQU $%.2x" % (each["map_group"])
        groups += "\n"
        maps += "MAP_"+ label + " EQU $%.2x" % (each["map_id"])
        maps += "\n"
        globals +=  label + " EQU $%.2x" % (id)
        globals += "\n"
        #for multi-byte constants:
        #print each["label"] + " EQUS \"$%.2x,$%.2x\"" % (each["map_group"], each["map_id"])
    logging.debug("globals: {0}".format(globals))
    logging.debug("groups: {0}".format(groups))
    logging.debug("maps: {0}".format(maps))

def generate_map_constants_dimensions():
    """
    Generate _WIDTH and _HEIGHT properties.
    """
    global map_internal_ids
    output = ""
    if map_internal_ids == None or map_internal_ids == {}:
        generate_map_constant_labels()
    for (id, each) in map_internal_ids.items():
        map_group = each["map_group"]
        map_id    = each["map_id"]
        label = each["label"].replace("-", "_").replace("é", "e").upper()
        output += label + "_HEIGHT EQU %d\n" % (map_names[map_group][map_id]["header_new"].second_map_header.height.byte)
        output += label + "_WIDTH EQU %d\n" % (map_names[map_group][map_id]["header_new"].second_map_header.width.byte)
    return output

def transform_wildmons(asm, map_internal_ids):
    """
    Converts a wildmons section to use map constants.
    input: wildmons text.
    """
    asmlines = asm.split("\n")
    returnlines = []
    for line in asmlines:
        if "; " in line and not ("day" in line or "morn" in line or "nite" in line or "0x" in line or "encounter" in line) \
        and line != "" and line.split("; ")[0] != "":
            map_group = int(line.split("\tdb ")[1].split(",")[0].replace("$", "0x"), base=16)
            map_id    = int(line.split("\tdb ")[1].split(",")[1].replace("$", "0x").split("; ")[0], base=16)
            label     = get_map_constant_label(map_group=map_group, map_id=map_id, map_internal_ids=map_internal_ids)
            returnlines.append("\tdb GROUP_"+label+", MAP_"+label) #+" ; " + line.split(";")[1])
        else:
            returnlines.append(line)
    return "\n".join(returnlines)

def parse_script_asm_at(*args, **kwargs):
    # XXX TODO
    logging.debug("TODO: parse_script_asm_at")
    return None

def find_all_text_pointers_in_script_engine_script(script, bank=None, debug=False):
    """returns a list of text pointers
    based on each script-engine script command"""
    # TODO: recursively follow any jumps in the script
    if script == None:
        return []
    addresses = set()
    for (k, command) in enumerate(script.commands):
        if debug:
            logging.debug("command is: {0}".format(command))
        if   command.id == 0x4B:
            addresses.add(command.params[0].parsed_address)
        elif command.id == 0x4C:
            addresses.add(command.params[0].parsed_address)
        elif command.id == 0x51:
            addresses.add(command.params[0].parsed_address)
        elif command.id == 0x53:
            addresses.add(command.params[0].parsed_address)
        elif command.id == 0x64:
            addresses.add(command.params[0].parsed_address)
            addresses.add(command.params[1].parsed_address)
    return addresses

def translate_command_byte(crystal=None, gold=None):
    """takes a command byte from either crystal or gold
    returns the command byte in the other (non-given) game

    The new commands are values 0x52 and 0x9F. This means:
        Crystal's 0x00–0x51 correspond to Gold's 0x00–0x51
        Crystal's 0x53–0x9E correspond to Gold's 0x52–0x9D
        Crystal's 0xA0–0xA5 correspond to Gold's 0x9E–0xA3

    see: http://www.pokecommunity.com/showpost.php?p=4347261
    """
    if crystal != None: # convert to gold
        if crystal <= 0x51: return crystal
        if crystal == 0x52: return None
        if 0x53 <= crystal <= 0x9E: return crystal-1
        if crystal == 0x9F: return None
        if 0xA0 <= crystal <= 0xA5: return crystal-2
        if crystal > 0xA5:
            raise Exception("dunno yet if crystal has new insertions after crystal:0xA5 (gold:0xA3)")
    elif gold != None: # convert to crystal
        if gold <= 0x51: return gold
        if 0x52 <= gold <= 0x9D: return gold+1
        if 0x9E <= gold <= 0xA3: return gold+2
        if gold > 0xA3:
            raise Exception("dunno yet if crystal has new insertions after gold:0xA3 (crystal:0xA5)")
    else:
        raise Exception("translate_command_byte needs either a crystal or gold command")

class SingleByteParam():
    """or SingleByte(CommandParam)"""
    size = 1
    should_be_decimal = False
    byte_type = "db"

    def __init__(self, *args, **kwargs):
        for (key, value) in kwargs.items():
            setattr(self, key, value)
        # check address
        if not hasattr(self, "address"):
            raise Exception("an address is a requirement")
        elif self.address == None:
            raise Exception("address must not be None")
        elif not is_valid_address(self.address):
            raise Exception("address must be valid")
        # check size
        if not hasattr(self, "size") or self.size == None:
            raise Exception("size is probably 1?")
        # parse bytes from ROM
        self.parse()

    def parse(self): self.byte = ord(rom[self.address])

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        return []

    def to_asm(self):
        if not self.should_be_decimal:
            return hex(self.byte).replace("0x", "$")
        else:
            return str(self.byte)

    @staticmethod
    def from_asm(value):
        return value

class DollarSignByte(SingleByteParam):
    def to_asm(self):
        return hex(self.byte).replace("0x", "$")
HexByte=DollarSignByte

class ItemLabelByte(DollarSignByte):
    def to_asm(self):
        label = item_constants.find_item_label_by_id(self.byte)
        if label:
            return label
        elif not label:
            return DollarSignByte.to_asm(self)


class DecimalParam(SingleByteParam):
    should_be_decimal = True


class MultiByteParam():
    """or MultiByte(CommandParam)"""
    size = 2
    should_be_decimal = False
    byte_type = "dw"

    def __init__(self, *args, **kwargs):
        self.prefix = "$" # default.. feel free to set 0x in kwargs
        for (key, value) in kwargs.items():
            setattr(self, key, value)
        # check address
        if not hasattr(self, "address") or self.address == None:
            raise Exception("an address is a requirement")
        elif not is_valid_address(self.address):
            raise Exception("address must be valid")
        # check size
        if not hasattr(self, "size") or self.size == None:
            raise Exception("don't know how many bytes to read (size)")
        self.parse()

    def parse(self):
        self.bytes = rom.interval(self.address, self.size, strings=False)
        self.parsed_number = self.bytes[0] + (self.bytes[1] << 8)
        if hasattr(self, "bank"):
            self.parsed_address = calculate_pointer_from_bytes_at(self.address, bank=self.bank)
        else:
            self.parsed_address = calculate_pointer_from_bytes_at(self.address, bank=None)

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        return []

    # you won't actually use this to_asm because it's too generic
    #def to_asm(self): return ", ".join([(self.prefix+"%.2x")%x for x in self.bytes])
    def to_asm(self):
        if not self.should_be_decimal:
            return self.prefix+"".join([("%.2x")%x for x in reversed(self.bytes)])
        elif self.should_be_decimal:
            decimal = int("0x"+"".join([("%.2x")%x for x in reversed(self.bytes)]), 16)
            return str(decimal)

    @staticmethod
    def from_asm(value):
        return value


class PointerLabelParam(MultiByteParam):
    # default size is 2 bytes
    default_size = 2
    size = 2
    # default is to not parse out a bank
    bank = False
    force = False
    debug = False

    def __init__(self, *args, **kwargs):
        self.dependencies = None
        # bank can be overriden
        if "bank" in kwargs.keys():
            if kwargs["bank"] != False and kwargs["bank"] != None and kwargs["bank"] in [True, "reverse"]:
                self.given_bank = kwargs["bank"]
            #if kwargs["bank"] not in [None, False, True, "reverse"]:
            #    raise Exception("bank cannot be: " + str(kwargs["bank"]))
        if self.size > 3:
            raise Exception("param size is too large")
        # continue instantiation.. self.bank will be set down the road
        MultiByteParam.__init__(self, *args, **kwargs)

    def parse(self):
        self.parsed_address = calculate_pointer_from_bytes_at(self.address, bank=self.bank)
        MultiByteParam.parse(self)

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        dependencies = []
        if self.parsed_address == self.address:
            return dependencies
        if self.dependencies != None and not recompute:
            global_dependencies.update(self.dependencies)
            return self.dependencies
        thing = script_parse_table[self.parsed_address]
        if thing and thing.address == self.parsed_address and not (thing is self):
            #if self.debug:
            #    print "parsed address is: " + hex(self.parsed_address) + " with label: " + thing.label.name + " of type: " + str(thing.__class__)
            dependencies.append(thing)
            if not thing in global_dependencies:
                global_dependencies.add(thing)
                more = thing.get_dependencies(recompute=recompute, global_dependencies=global_dependencies)
                dependencies.extend(more)
        self.dependencies = dependencies
        return dependencies

    def to_asm(self):
        bank = self.bank
        # we pass bank= for whether or not to include a bank byte when reading
        #.. it's not related to caddress
        caddress = None
        if not (hasattr(self, "parsed_address") and self.parsed_address != None):
            caddress = calculate_pointer_from_bytes_at(self.address, bank=self.bank)
        else:
            caddress = self.parsed_address
        label = get_label_for(caddress)
        pointer_part = label # use the label, if it is found

        # check that the label actually points to the right place
        result = script_parse_table[caddress]
        if result != None and hasattr(result, "label"):
            if result.label.name != label:
                label = None
            elif result.address != caddress:
                label = None
        elif result != None:
            label = None

        # setup output bytes if the label was not found
        if not label:
            if bank == True:
                lo, hi = self.bytes[1:3]
            else:
                lo, hi = self.bytes[0:2]
            pointer_part = "{0}{1:02x}{2:02x}".format(self.prefix, hi, lo)

        # bank positioning matters!
        if bank == True or bank == "reverse": # bank, pointer
            # possibly use BANK(LABEL) if we know the bank
            if label:
                bank_part = "BANK({})".format(label)
            else:
                if "$" in pointer_part:
                    if 0x4000 <= caddress <= 0x7FFF:
                        #bank_part = "$%.2x" % (pointers.calculate_bank(self.parent.parent.address))
                        bank_part = "1"
                    else:
                        bank_part = "$%.2x" % (pointers.calculate_bank(caddress))
                else:
                    bank_part = ((self.prefix+"%.2x")%bank)
            # for labels, expand bank_part at build time
            if bank in ["reverse", True] and label:
                return label
            # return the asm based on the order the bytes were specified to be in
            elif bank == "reverse": # pointer, bank
                return pointer_part+", "+bank_part
            elif bank == True: # bank, pointer
                return bank_part+", "+pointer_part
            else:
                raise Exception("this should never happen")
            raise Exception("this should never happen")
        # this next one will either return the label or the raw bytes
        elif bank == False or bank == None: # pointer
            return pointer_part # this could be the same as label
        else:
            #raise Exception("this should never happen")
            return pointer_part # probably in the same bank ?
        raise Exception("this should never happen")

class PointerLabelBeforeBank(PointerLabelParam):
    size = 3
    bank = True # bank appears first, see calculate_pointer_from_bytes_at
    byte_type = 'db'

    @staticmethod
    def from_asm(value):
        return 'BANK({0})\n\tdw {0}'.format(value)

class PointerLabelAfterBank(PointerLabelParam):
    size = 3
    bank = "reverse" # bank appears last, see calculate_pointer_from_bytes_at
    byte_type = 'dw'

    @staticmethod
    def from_asm(value):
        return '{0}\n\tdb BANK({0})'.format(value)


class ScriptPointerLabelParam(PointerLabelParam): pass


class ScriptPointerLabelBeforeBank(PointerLabelBeforeBank): pass


class ScriptPointerLabelAfterBank(PointerLabelAfterBank): pass


def _parse_script_pointer_bytes(self, debug = False):
    PointerLabelParam.parse(self)
    if debug:
        logging.debug(
            "_parse_script_pointer_bytes - calculating the pointer located at {0}"
            .format(hex(self.address))
        )
    address = calculate_pointer_from_bytes_at(self.address, bank=self.bank)
    if address != None and address > 0x4000:
        if debug:
            logging.debug(
                "_parse_script_pointer_bytes - the pointer is: {0}"
                .format(hex(address))
            )
        self.script = parse_script_engine_script_at(address, debug=self.debug, force=self.force, map_group=self.map_group, map_id=self.map_id)
ScriptPointerLabelParam.parse = _parse_script_pointer_bytes
ScriptPointerLabelBeforeBank.parse = _parse_script_pointer_bytes
ScriptPointerLabelAfterBank.parse = _parse_script_pointer_bytes

class PointerLabelToScriptPointer(PointerLabelParam):
    def parse(self):
        PointerLabelParam.parse(self)
        address = calculate_pointer_from_bytes_at(self.parsed_address, bank=self.bank)
        address2 = calculate_pointer_from_bytes_at(address, bank=True)
        self.script = parse_script_engine_script_at(address2, origin=False, map_group=self.map_group, map_id=self.map_id, force=self.force, debug=self.debug)


class AsmPointerParam(PointerLabelBeforeBank):
    def parse(self):
        PointerLabelBeforeBank.parse(self)
        address = calculate_pointer_from_bytes_at(self.address, bank=self.bank) # 3-byte pointer
        self.asm = parse_script_asm_at(address, map_group=self.map_group, map_id=self.map_id, force=self.force, debug=self.debug) # might end in some specific way?


class PointerToAsmPointerParam(PointerLabelParam):
    def parse(self):
        PointerLabelParam.parse(self)
        address = calculate_pointer_from_bytes_at(self.address, bank=self.bank) # 2-byte pointer
        address2 = calculate_pointer_from_bytes_at(address, bank="reverse") # maybe not "reverse"?
        self.asm = parse_script_asm_at(address, map_group=self.map_group, map_id=self.map_id, force=self.force, debug=self.debug) # might end in some specific way?


class RAMAddressParam(MultiByteParam):
    def to_asm(self):
        address = calculate_pointer_from_bytes_at(self.address, bank=False)
        label = get_ram_label(address)
        if label:
            return label
        else:
            return "$"+"".join(["%.2x"%x for x in reversed(self.bytes)])+""


class MoneyByteParam(MultiByteParam):
    size = 3
    byte_type = "db"
    max_value = 0x0F423F
    should_be_decimal = True
    def parse(self):
        MultiByteParam.parse(self)
        # in the rom as xxyyzz
        self.x = self.bytes[2]
        self.y = self.bytes[1]
        self.z = self.bytes[0]
    def to_asm(self):
        return str(self.x + (self.y << 8) + (self.z << 16))

    # this is used by the preprocessor
    @staticmethod
    def from_asm(value):
        # max is 0F423F
        # z = 0x0F ; y = 0x42 ; x = 0x3F
        # 999999 = x + (y << 8) + (z << 16)

        value = int(value)

        x = (value & 0x0000FF)
        y = (value & 0x00FF00) >> 8
        z = (value & 0xFF0000) >> 16

        return str(z) + "\ndb "+str(y)+"\ndb "+str(x)

def read_money(address, dohex=False):
    z = ord(rom[address])
    y = ord(rom[address+1])
    x = ord(rom[address+2])
    answer = x + (y << 8) + (z << 16)
    if not dohex:
        return answer
    else:
        return hex(answer)

def write_money(money):
    value = money
    x = (value & 0x0000FF)
    y = (value & 0x00FF00) >> 8
    z = (value & 0xFF0000) >> 16
    return "db "+str(z)+"\ndb "+str(y)+"\ndb "+str(x)

class CoinByteParam(MultiByteParam):
    size = 2
    max_value = 0x270F
    should_be_decimal = True


class MapGroupParam(SingleByteParam):
    def to_asm(self):
        map_id = ord(rom[self.address+1])
        map_constant_label = get_map_constant_label(map_id=map_id, map_group=self.byte, map_internal_ids=self.map_internal_ids) # like PALLET_TOWN
        if map_constant_label == None:
            return str(self.byte)
        #else: return "GROUP("+map_constant_label+")"
        else:
            return "GROUP_"+map_constant_label


class MapIdParam(SingleByteParam):
    def parse(self):
        SingleByteParam.parse(self)
        self.map_group = ord(rom[self.address-1])

    def to_asm(self):
        map_group = ord(rom[self.address-1])
        map_constant_label = get_map_constant_label(map_id=self.byte, map_group=map_group, map_internal_ids=self.map_internal_ids)
        if map_constant_label == None:
            return str(self.byte)
        #else: return "MAP("+map_constant_label+")"
        else:
            return "MAP_"+map_constant_label


class MapGroupIdParam(MultiByteParam):
    def parse(self):
        MultiByteParam.parse(self)
        self.map_group = self.bytes[0]
        self.map_id = self.bytes[1]

    def to_asm(self):
        map_group = self.map_group
        map_id = self.map_id
        label = get_map_constant_label(map_group=map_group, map_id=map_id, map_internal_ids=self.map_internal_ids)
        return label


class PokemonParam(SingleByteParam):
    def to_asm(self):
        pokemon_constant = get_pokemon_constant_by_id(self.byte)
        if pokemon_constant:
            return pokemon_constant
        else:
            return str(self.byte)

class PokemonWordParam(MultiByteParam):
    def to_asm(self):
        pokemon_constant = get_pokemon_constant_by_id(self.parsed_number)
        if pokemon_constant:
            return pokemon_constant
        else:
            return str(self.parsed_number)


class PointerParamToItemAndLetter(MultiByteParam):
    # [2F][2byte pointer to item no + 0x20 bytes letter text]
    pass


class TrainerIdParam(SingleByteParam):
    def to_asm(self):
        # find the group id by first finding the param type id
        i = 0
        foundit = None
        for (k, v) in self.parent.param_types.items():
            if v["class"] == TrainerGroupParam:
                foundit = i
                break
            i += 1

        if foundit == None:
            raise Exception("didn't find a TrainerGroupParam in this command??")

        # now get the trainer group id
        trainer_group_id = self.parent.params[foundit].byte

        # check the rule to see whether to use an id or not
        if ("uses_numeric_trainer_ids" in trainers.trainer_group_names[trainer_group_id].keys()) or \
           (not "trainer_names" in trainers.trainer_group_names[trainer_group_id].keys()):
            return str(self.byte)
        else:
            return trainers.trainer_group_names[trainer_group_id]["trainer_names"][self.byte-1]

class TrainerGroupParam(SingleByteParam):
    def to_asm(self):
        trainer_group_id = self.byte
        return trainers.trainer_group_names[trainer_group_id]["constant"]

class MoveParam(SingleByteParam):
    def to_asm(self):
        if self.byte in move_constants.moves.keys():
            return move_constants.moves[self.byte]
        else:
            # this happens for move=0 (no move) in trainer headers
            return str(self.byte)

class MenuDataPointerParam(PointerLabelParam):
    """read menu data at the target site"""


string_to_text_texts = []
class RawTextPointerLabelParam(PointerLabelParam):
    # not sure if these are always to a text script or raw text?
    def parse(self):
        PointerLabelParam.parse(self)
        #bank = pointers.calculate_bank(self.address)
        address = calculate_pointer_from_bytes_at(self.address, bank=False)
        self.calculated_address = address
        #self.text = parse_text_at3(address, map_group=self.map_group, map_id=self.map_id, debug=self.debug)
        #self.text = TextScript(address, map_group=self.map_group, map_id=self.map_id, debug=self.debug)
        self.text = parse_text_engine_script_at(address, map_group=self.map_group, map_id=self.map_id, debug=self.debug)

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        global_dependencies.add(self.text)
        return [self.text]

class EncodedTextLabelParam(PointerLabelParam):
    def parse(self):
        PointerLabelParam.parse(self)

        address = calculate_pointer_from_bytes_at(self.address, bank=False)
        self.parsed_address = address
        self.text = EncodedText(address, map_group=self.map_group, map_id=self.map_id, debug=self.debug)

        if isinstance(self.text, EncodedText):
            string_to_text_texts.append(self.text)

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        global_dependencies.add(self.text)
        return [self.text]

class TextPointerLabelParam(PointerLabelParam):
    """this is a pointer to a text script"""
    bank = False
    text = None
    def parse(self):
        PointerLabelParam.parse(self)
        address = calculate_pointer_from_bytes_at(self.address, bank=self.bank)
        if address != None and address != 0:
            self.text = parse_text_engine_script_at(address, map_group=self.map_group, map_id=self.map_id, force=self.force, debug=self.debug)
            if not self.text:
                self.text = script_parse_table[address]

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        if self.text:
            global_dependencies.add(self.text)
            return [self.text]
        else:
            return []

class TextPointerLabelAfterBankParam(PointerLabelAfterBank):
    text = None
    def parse(self):
        PointerLabelAfterBank.parse(self)
        address = calculate_pointer_from_bytes_at(self.address, bank=self.bank)
        if address != None and address != 0:
            self.text = parse_text_engine_script_at(address, map_group=self.map_group, map_id=self.map_id, force=self.force, debug=self.debug)
            if not self.text:
                self.text = script_parse_table[address]

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        if self.text:
            global_dependencies.add(self.text)
            return [self.text]
        else:
            return []

class MovementPointerLabelParam(PointerLabelParam):
    def parse(self):
        PointerLabelParam.parse(self)
        if is_script_already_parsed_at(self.parsed_address):
            self.movement = script_parse_table[self.parsed_address]
        else:
            self.movement = ApplyMovementData(self.parsed_address, map_group=self.map_group, map_id=self.map_id, debug=self.debug)

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        if hasattr(self, "movement") and self.movement:
            global_dependencies.add(self.movement)
            return [self.movement] + self.movement.get_dependencies(recompute=recompute, global_dependencies=global_dependencies)
        else:
            raise Exception("MovementPointerLabelParam hasn't been parsed yet")

class MapDataPointerParam(PointerLabelParam):
    pass

class Command:
    """
    Note: when dumping to asm, anything in script_parse_table that directly
    inherits Command should not be .to_asm()'d.
    """
    # use this when the "byte id" doesn't matter
    # .. for example, a non-script command doesn't use the "byte id"
    override_byte_check = False
    is_rgbasm_macro = False
    base_label = "UnseenLabel_"

    def __init__(self, address=None, *pargs, **kwargs):
        """params:
        address     - where the command starts
        force       - whether or not to force the script to be parsed (default False)
        debug       - are we in debug mode? default False
        map_group
        map_id
        """
        defaults = {"force": False, "debug": False, "map_group": None, "map_id": None}
        if not is_valid_address(address):
            raise Exception("address is invalid")
        # set up some variables
        self.address = address
        self.last_address = None
        # setup the label based on base_label if available
        label = self.base_label + hex(self.address)
        self.label = Label(name=label, address=address, object=self)
        # params are where this command's byte parameters are stored
        self.params = {}
        self.dependencies = None
        # override default settings
        defaults.update(kwargs)
        # set everything
        for (key, value) in defaults.items():
            setattr(self, key, value)
        # but also store these kwargs
        self.args = defaults
        # start parsing this command's parameter bytes
        self.parse()

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        dependencies = []
        #if self.dependencies != None and not recompute:
        #    global_dependencies.update(self.dependencies)
        #    return self.dependencies
        for (key, param) in self.params.items():
            if hasattr(param, "get_dependencies") and param != self:
                deps = param.get_dependencies(recompute=recompute, global_dependencies=global_dependencies)
                if deps != None and not self in deps:
                    dependencies.extend(deps)
        self.dependencies = dependencies
        return dependencies

    def to_asm(self):
        # start with the rgbasm macro name for this command
        output = ""
        #if len(self.macro_name) > 0 and self.macro_name[0].isdigit():
        #    output += "_"
        output += self.macro_name
        # return if there are no params
        if len(self.param_types.keys()) == 0:
            return output
        # first one will have no prefixing comma
        first = True
        # start reading the bytes after the command byte
        if not self.override_byte_check:
            current_address = self.address+1
        else:
            current_address = self.address
        #output = self.macro_name + ", ".join([param.to_asm() for (key, param) in self.params.items()])
        # add each param
        for (key, param) in self.params.items():
            name = param.name
            # the first param shouldn't have ", " prefixed
            if first:
                output += " "
                first = False
            # but all other params should
            else: output += ", "
            # now add the asm-compatible param string
            output += param.to_asm()
            current_address += param.size
        #for param_type in self.param_types:
        #    name = param_type["name"]
        #    klass = param_type["klass"]
        #    # create an instance of this type
        #    # tell it to begin parsing at this latest byte
        #    obj = klass(address=current_address)
        #    # the first param shouldn't have ", " prefixed
        #    if first: first = False
        #    # but all other params should
        #    else: output += ", "
        #    # now add the asm-compatible param string
        #    output += obj.to_asm()
        #    current_address += obj.size
        return output

    def parse(self):
        # id, size (inclusive), param_types
        #param_type = {"name": each[1], "class": each[0]}
        if not self.override_byte_check:
            current_address = self.address+1
        else:
            current_address = self.address
        byte = ord(rom[self.address])
        if not self.override_byte_check and (not byte == self.id):
            raise Exception("byte ("+hex(byte)+") != self.id ("+hex(self.id)+")")
        i = 0
        for (key, param_type) in self.param_types.items():
            name = param_type["name"]
            klass = param_type["class"]
            # make an instance of this class, like SingleByteParam()
            # or ItemLabelByte.. by making an instance, obj.parse() is called
            obj = klass(address=current_address, name=name, parent=self, **dict([(k,v) for (k, v) in self.args.items() if k not in ["parent"]]))
            # save this for later
            self.params[i] = obj
            # increment our counters
            current_address += obj.size
            i += 1
        self.last_address = current_address
        return True


class GivePoke(Command):
    id = 0x2D
    macro_name = "givepoke"
    size = 4 # minimum
    end = False
    param_types = {
                  0: {"name": "pokemon", "class": PokemonParam},
                  1: {"name": "level", "class": DecimalParam},
                  2: {"name": "item", "class": ItemLabelByte},
                  3: {"name": "trainer", "class": DecimalParam},
                  4: {"name": "trainer_name_pointer", "class": MultiByteParam}, # should probably use TextLabelParam
                  5: {"name": "pkmn_nickname", "class": MultiByteParam}, # XXX TextLabelParam ?
                  }
    allowed_lengths = [4, 6]

    def parse(self):
        self.params = {}
        byte = ord(rom[self.address])
        if not byte == self.id:
            raise Exception("this should never happen")
        current_address = self.address+1
        i = 0
        self.size = 1
        for (key, param_type) in self.param_types.items():
            # stop executing after the 4th byte unless it == 0x1
            if i == 4:
                logging.debug("self.params[3].byte is: {0}".format(str(self.params[3].byte)))
            if i == 4 and self.params[3].byte != 1: break
            name = param_type["name"]
            klass = param_type["class"]
            # make an instance of this class, like SingleByteParam()
            # or ItemLabelByte.. by making an instance, obj.parse() is called
            obj = klass(address=current_address, name=name)
            # save this for later
            self.params[i] = obj
            # increment our counters
            current_address += obj.size
            self.size += obj.size
            i += 1
        self.last_address = current_address
        return True

class DataByteWordMacro(Command):
    """
    Only used by the preprocessor.
    """

    id = None
    macro_name = "dbw"
    size = 3
    override_byte_check = True

    param_types = {
        0: {"name": "db value", "class": DecimalParam},
        1: {"name": "dw value", "class": PointerLabelParam},
    }

    def __init__(self): pass
    def parse(self): pass
    def to_asm(self): pass


event_flags = None
def read_event_flags():
    global event_flags
    constants = wram.read_constants(os.path.join(conf.path, 'constants.asm'))
    event_flags = dict(filter(lambda (key, value): value.startswith('EVENT_'), constants.items()))

engine_flags = None
def read_engine_flags():
    global engine_flags
    constants = wram.read_constants(os.path.join(conf.path, 'constants.asm'))
    engine_flags = dict(filter(lambda (key, value): value.startswith('ENGINE_'), constants.items()))

class EventFlagParam(MultiByteParam):
    def to_asm(self):
        if event_flags is None: read_event_flags()
        return event_flags.get(self.parsed_number) or MultiByteParam.to_asm(self)

class EngineFlagParam(MultiByteParam):
    def to_asm(self):
        if engine_flags is None: read_engine_flags()
        return engine_flags.get(self.parsed_number) or MultiByteParam.to_asm(self)


class MovementCommand(Command):
    # the vast majority of movement commands do not end the movement script
    end = False

    # this is only used for e.g. macros that don't appear as a byte in the ROM
    # don't use the override because all movements are specified with a byte
    override_byte_check = False

    # most commands have size=1 but one or two have a single parameter (gasp)
    size = 1

    param_types = {}
    params = []

    # most movement commands won't have any dependencies
    # get_dependencies on Command will look at the values of params
    # so this doesn't need to be specified by MovementCommand as long as it extends Command
    #def get_dependencies(self, recompute=False, global_dependencies=set()):
    #    return []

    def parse(self):
        if ord(rom[self.address]) < 0x45:
            # this is mostly handled in to_asm
            pass
        else:
            Command.parse(self)

    def to_asm(self):
        # return "db $%.2x"%(self.byte)
        return Command.to_asm(self)

class MovementDBCommand(Command):
    end = False
    macro_name = "db"
    override_byte_check = True
    id = None
    byte = None
    size = 1
    param_types = {
        0: {"name": "db value", "class": SingleByteParam},
    }
    params = []

    def to_asm(self):
        asm = Command.to_asm(self)
        return asm + " ; movement"

# down, up, left, right
movement_command_bases = {
    0x00: "turn_head",
    0x04: "half_step",
    0x08: "slow_step", # small_step?
    0x0C: "step",
    0x10: "big_step", # fast_step?
    0x14: "slow_slide_step",
    0x18: "slide_step",
    0x1C: "fast_slide_step",
    0x20: "turn_away",
    0x24: "turn_in", # towards?
    0x28: "turn_waterfall", # what??
    0x2C: "slow_jump_step",
    0x30: "jump_step",
    0x34: "fast_jump_step",

    # tauwasser says the pattern stops at $45 but $38 looks more realistic?
    0x3A: "remove_fixed_facing",
    0x3B: "fix_facing",
    0x3D: "hide_person",
    0x3E: "show_person",
    0x45: "accelerate_last",
    0x46: ["step_sleep", ["duration", DecimalParam]],
    0x47: "step_end",
    0x49: "remove_person",

    # do these next two have any params ??
    0x4C: "teleport_from",
    0x4D: "teleport_to",

    0x4E: "skyfall",
    0x4F: "step_wait5",
    0x53: "hide_emote",
    0x54: "show_emote",
    0x55: ["step_shake", ["displacement", DecimalParam]],
}

# create MovementCommands from movement_command_bases
def create_movement_commands(debug=False):
    """
    Creates MovementCommands from movement_command_bases. This is just a cheap
    trick instead of manually defining all of those classes.
    """
    #movement_command_classes = inspect.getmembers(sys.modules[__name__], \
    #                       lambda obj: inspect.isclass(obj) and \
    #                       issubclass(obj, MovementCommand) and \
    #                       not (obj is MovementCommand))
    movement_command_classes2 = []
    for (byte, cmd) in movement_command_bases.items():
        if type(cmd) == str:
            cmd = [cmd]
        cmd_name = cmd[0].replace(" ", "_")
        params = {"id": byte, "size": 1, "end": byte is 0x47, "macro_name": cmd_name}
        params["param_types"] = {}
        if len(cmd) > 1:
            param_types = cmd[1:]
            for (i, each) in enumerate(param_types):
                thing = {"name": each[0], "class": each[1]}
                params["param_types"][i] = thing
                if debug:
                    logging.debug(
                        "each is {0} and thing[class] is {1}"
                        .format(each, str(thing["class"]))
                    )
                params["size"] += thing["class"].size

        if byte <= 0x34:
            for x in range(0, 4):

                direction = None
                if x == 0:
                    direction = "down"
                elif x == 1:
                    direction = "up"
                elif x == 2:
                    direction = "left"
                elif x == 3:
                    direction = "right"
                else:
                    raise Exception("this should never happen")

                cmd_name = cmd[0].replace(" ", "_") + "_" + direction
                klass_name = cmd_name+"Command"
                params["id"] = copy(byte)
                params["macro_name"] = cmd_name
                klass = classobj(copy(klass_name), (MovementCommand,), deepcopy(params))
                globals()[klass_name] = klass
                movement_command_classes2.append(klass)

                byte += 1
            del cmd_name
            del params
            del klass_name
        else:
            klass_name = cmd_name+"Command"
            klass = classobj(klass_name, (MovementCommand,), params)
            globals()[klass_name] = klass
            movement_command_classes2.append(klass)
    # later an individual klass will be instantiated to handle something
    return movement_command_classes2

movement_command_classes = create_movement_commands()

all_movements = []
class ApplyMovementData:
    base_label = "MovementData_"

    def __init__(self, address, map_group=None, map_id=None, debug=False, label=None, force=False):
        self.address   = address
        self.map_group = map_group
        self.map_id    = map_id
        self.debug     = debug
        self.force     = force

        if not label:
            label = self.base_label + hex(address)
        self.label     = Label(name=label, address=address, object=self)

        self.dependencies = []
        self.commands     = []

        self.parse()

    # this is almost an exact copy of Script.parse
    # with the exception of using text_command_classes instead of command_classes
    def parse(self):
        global movement_command_classes, script_parse_table
        address = self.address

        # i feel like checking myself
        if not is_valid_address(address):
            raise exceptions.AddressException(
                "ApplyMovementData.parse must be given a valid address (but got {0})."
                .format(hex(address))
            )

        current_address = copy(self.address)
        start_address = copy(current_address)

        # don't clutter up my screen
        if self.debug:
            logging.debug(
                "ApplyMovementData.parse address={address} map_group={map_group} map_id={map_id}"
                .format(
                    address=hex(self.address),
                    map_group=str(self.map_group),
                    map_id=str(self.map_id),
                )
            )

        # load up the rom if it hasn't been loaded already
        rom = load_rom()

        # in the event that the script parsing fails.. it would be nice to leave evidence
        script_parse_table[start_address:start_address+1] = "incomplete ApplyMovementData.parse"

        # start with a blank script
        commands = []

        # use this to control the while loop
        end = False

        # for each command found...
        while not end:
            # get the current scripting byte
            cur_byte = ord(rom[current_address])

            # reset the command class (last command was probably different)
            scripting_command_class = None

            # match the command id byte to a scripting command class like "step half"
            for class_ in movement_command_classes:
                # allow lists of ids
                if (type(class_.id) == list and cur_byte in class_.id) \
                   or class_.id == cur_byte:
                    scripting_command_class = class_

            # temporary fix for applymovement scripts
            if ord(rom[current_address]) == 0x47:
                end = True

            # no matching command found
            xyz = None
            if scripting_command_class == None:
                scripting_command_class = MovementDBCommand
                #scripting_command_class = deepcopy(MovementCommand)
                #scripting_command_class.id = scripting_command_class.byte = ord(rom[current_address])
                #scripting_command_class.macro_name = "db"
                #scripting_command_class.size = 1
                #scripting_command_class.override_byte_check = True
                #scripting_command_class.id = None
                #scripting_command_class.param_types = {0: {"name": "db value", "class": DecimalParam}}

                xyz = True

            # create an instance of the command class and let it parse its parameter bytes
            cls = scripting_command_class(address=current_address, map_group=self.map_group, map_id=self.map_id, debug=self.debug, force=self.force)

            if self.debug:
                logging.debug("cls.to_asm() is: {0}".format(cls.to_asm()))

            # store it in this script object
            commands.append(cls)

            # certain commands will end the movement engine
            end = cls.end

            # skip past the command's parameter bytes to go to the next command
            current_address += cls.size

        # last byte belonging to script is last byte of last command,
        # or the last byte of the last command's last parameter
        # (actually i think this might be the next byte after??)
        self.last_address = current_address

        # store the script in the global table/map thing
        all_movements.append(self)
        script_parse_table[start_address:current_address] = self

        if self.debug:
            asm_output = "\n".join([command.to_asm() for command in commands])
            logging.debug("asm_output: {0}".format(asm_output))

        # store the script
        self.commands = commands
        return commands

    def to_asm(self):
        asm_output = "\n".join([command.to_asm() for command in self.commands])
        return asm_output

    # TODO: get_dependencies doesn't work if ApplyMovementData uses labels in the future
    def get_dependencies(self, recompute=False, global_dependencies=set()):
        return []

def print_all_movements():
    for each in all_movements:
        print each.to_asm()
        print "------------------"
    print "done"

class TextCommand(Command):
    # an individual text command will not end it
    end = False

    # this is only used for e.g. macros that don't appear as a byte in the ROM
    # don't use the override because all text commands are specified with a byte
    override_byte_check = False

    # in the case of text/asm commands, size is unknown until after parsing
    # some text commands can specify this upfront but not $0
    size = None

    param_types = {}
    params = []

    # most text commands won't have any dependencies
    # .. except for that one that points to another location for text
    # get_dependencies on Command will look at the values of params
    # so this doesn't need to be specified by TextCommand as long as it extends Command
    #def get_dependencies(self, recompute=False, global_dependencies=set()):
    #    return []


# this is a regular command in a TextScript for writing text
# but unlike other macros that preprocessor.py handles,
# the preprocessor-parser is custom and MainText is not
# used as a macro by main.asm - however, MainText is
# treated as a macro for the sake of parsing the ROM because
# it is called with $0. This is very similar to how Script
# is parsed and handled. But again, script command macros
# are quite different.. preprocessor.py allows some of them
# to handle how they should be parsed from main.asm, in
# addition to their regular "parse()" method.
class MainText(TextCommand):
    "Write text. Structure: [00][Text][0x50 (ends code)]"
    id = 0x0
    macro_name = "do_text"
    use_zero = True

    def parse(self):
        offset = self.address

        # the code below assumes we're jumping past a $0 byte
        if self.use_zero == False:
            offset = offset
        else:
            offset = offset + 1

        # read until $50, $57 or $58 (not sure about $58...)
        jump57 = how_many_until(chr(0x57), offset, rom)
        jump50 = how_many_until(chr(0x50), offset, rom)
        jump58 = how_many_until(chr(0x58), offset, rom)

        # pick whichever one comes first
        jump = min([jump57, jump50, jump58])

        # if $57 appears first then this command is the last in this text script
        if jump == jump57 or jump == jump58:
            self.end = True

        jump += 1

        # we want the address after the $57
        # ("last_address" is misnamed everywhere)
        end_address = offset + jump
        self.last_address = self.end_address = end_address

        # read the text bytes into a structure
        # skip the first offset byte because that's the command byte
        self.bytes = rom.interval(offset, jump, strings=False)

        # include the original command in the size calculation
        self.size = jump

        if self.use_zero:
            self.last_address = self.address + jump + 1
            self.size = self.last_address - self.address

            if self.address == 0x9c00e and self.debug:
                if self.last_address != 0x9c086:
                    argparams = {
                        "self.address": hex(self.address),
                        "jump": str(jump),
                        "bytes": str(self.bytes),
                        "self.size": str(self.size),
                        "self.last_address": hex(self.last_address),
                    }

                    logging.debug(str(argparams))

                    raise Exception("last_address is wrong for 0x9c00e")

    def to_asm(self):
        if self.size < 2 or len(self.bytes) < 1:
            raise Exception("$0 text command can't end itself with no follow-on bytes")

        if self.use_zero:
            output = "db $0"
        else:
            output = ""

        # db $0, $57 or db $0, $50 or w/e
        if self.size == 2 and len(self.bytes) == 1:
            output += ", $%.2x" % (self.bytes[0])
            return output

        # whether or not quotes are open
        in_quotes = False

        # whether or not to print "db " next
        new_line = False

        # whether or not there was a ", " last..
        # this is useful outside of quotes
        was_comma = False

        # has a $50 or $57 been passed yet?
        end = False

        if not self.use_zero:
            new_line = True
            was_comma = False

        for byte in self.bytes:
            if end:
                raise Exception("the text ended due to a $50 or $57 but there are more bytes?")

            if new_line:
                if in_quotes:
                    raise Exception("can't be in_quotes on a newline")
                elif was_comma:
                    raise Exception("last line's last character can't be a comma")

                output += "db "

            # $4f, $51 and $55 can end a line
            if byte in [0x4f, 0x51, 0x55]:
                if new_line:
                    raise exceptions.TextScriptException("can't have $4f, $51, $55 as the first character on a newline")

                if in_quotes:
                    output += "\", $%.2x\n" % (byte)
                elif not in_quotes:
                    if not was_comma:
                        output += ", "
                    output += "$%.2x\n" % (byte)

                # reset everything
                in_quotes = False
                new_line  = True
                was_comma = False
            elif byte == 0x50:
                # technically you could have this i guess... db "@"
                # but in most situations it will be added to the end of the previous line
                #assert not new_line, "can't have $50 or '@' as the first character on a newline in the text at "+hex(self.address)

                if in_quotes:
                    output += "@\"\n"
                    new_line = True
                elif not in_quotes:
                    if not was_comma and not new_line:
                        output += ", "
                    output += "\"@\"\n"

                # reset everything
                in_quotes = False
                new_line  = True
                was_comma = False
                end       = True

                # self.end should be set in parse or constructor
                # so this is very useless here.. but it's a truism i guess
                self.end  = True
            elif byte == 0x57 or byte == 0x58:
                # close any quotes
                if in_quotes:
                    output += "\""
                    was_comma = False

                if not was_comma and not new_line:
                    output += ", "

                output += "$%.2x\n" % (byte)

                in_quotes = False
                new_line  = True
                was_comma = False
                end       = True

                # dunno if $58 should end a text script or not
                # also! self.end should be set in parse not in to_asm
                # so this is pretty useless overall...
                if byte == 0x58:
                    self.end = True
            elif byte in chars.chars.keys():
                # figure out what the character actually is
                char = chars.chars[byte]

                # oh wait.. quotes isn't a valid character in the first place :(
                if char == "\"":
                    if in_quotes:
                        output += "\""
                        in_quotes = False
                    elif not in_quotes:
                        if new_line:
                            output += "\""
                        elif not new_line:
                            if not was_comma:
                                output += ", "
                            output += "\""
                        in_quotes = True

                # the above if statement is probably never called
                else:
                    if not in_quotes:
                        if not new_line and not was_comma:
                            output += ", "
                        output += "\""
                        in_quotes = True

                    output += char

                new_line  = False
                was_comma = False
                end       = False
            else:
                # raise Exception("unknown byte in text script ($%.2x)" % (byte))
                # just add an unknown byte directly to the text.. what's the worse that can happen?

                if in_quotes:
                    output += "\", $%.2x" % (byte)

                    in_quotes = False
                    was_comma = False
                    new_line = False
                elif not in_quotes:
                    if not was_comma and not new_line:
                        output += ", "
                    output += "$%.2x" % (byte)

                # reset things
                in_quotes = False
                new_line  = False
                was_comma = False

        # this shouldn't happen because of the rom_until calls in the parse method
        if not end:
            raise Exception("ran out of bytes without the script ending? starts at "+hex(self.address))

        # last character may or may not be allowed to be a newline?
        # Script.to_asm() has command.to_asm()+"\n"
        if output[-1] == "\n":
            output = output[:-1]

        return output

class PokedexText(MainText):
    use_zero = False

class WriteTextFromRAM(TextCommand):
    """
    Write text from ram. Structure: [01][Ram address (2byte)]
    For valid ram addresses see Glossary. This enables use of variable text strings.
    """
    id = 0x1
    macro_name = "text_from_ram"
    size = 3
    param_types = {
        0: {"name": "pointer", "class": MultiByteParam},
    }
class WriteNumberFromRAM(TextCommand):
    """
    02 = Write number from ram. Structure: [02][Ram address (2byte)][Byte]

    Byte:

    Bit5:Bit6:Bit7
       1:   1:   1 = PokéDollar| Don’t write zeros
       0:   1:   1 = Don’t write zeros
       0:   0:   1 = Spaces instead of zeros
       0:   0:   0 = Write zeros
       0:   1:   0 = Write zeros
       1:   0:   0 = PokéDollar
       1:   1:   0 = PokéDollar
       1:   0:   1 = Spaces instead of zeros| PokéDollar

    Number of figures = Byte AND 0x1F *2
    No Hex --> Dec Conversio
    """
    id = 0x2
    macro_name = "number_from_ram"
    size = 4
    param_types = {
        0: {"name": "pointer", "class": PointerLabelParam},
        1: {"name": "config", "class": HexByte},
    }
class SetWriteRAMLocation(TextCommand):
    "Define new ram address to write to. Structure: [03][Ram address (2byte)]"
    id = 0x3
    macro_name = "store_at"
    size = 3
    param_types = {
        0: {"name": "ram address", "class": PointerLabelParam},
    }
class ShowBoxWithValueAt(TextCommand):
    "04 = Write a box. Structure: [04][Ram address (2byte)][Y][X]"
    id = 0x4
    macro_name = "text_box"
    size = 5
    param_types = {
        0: {"name": "ram address", "class": PointerLabelParam},
        1: {"name": "y", "class": DecimalParam},
        2: {"name": "x", "class": DecimalParam},
    }
class Populate2ndLineOfTextBoxWithRAMContents(TextCommand):
    "05 = New ram address to write to becomes 2nd line of a text box. Structure: [05]"
    id = 0x5
    macro_name = "text_dunno1"
    size = 1
class ShowArrowsAndButtonWait(TextCommand):
    "06 = Wait for key down + show arrows. Structure: [06]"
    id = 0x6
    macro_name = "text_waitbutton"
    size = 1
class Populate2ndLine(TextCommand):
    """
    07 = New ram address to write to becomes 2nd line of a text box
    Textbox + show arrows. Structure: [07]
    """
    id = 0x7
    macro_name = "text_dunno2"
    size = 1
class TextInlineAsm(TextCommand):
    "08 = After the code an ASM script starts. Structure: [08][Script]"
    id = 0x8
    macro_name = "start_asm"
    end = True
    size = 1
    # TODO: parse the following asm with gbz80disasm
class WriteDecimalNumberFromRAM(TextCommand):
    """
    09 = Write number from rom/ram in decimal. Structure: [09][Ram address/Pointer (2byte)][Byte]
      Byte:

      Is split: 1. 4 bits = Number of bytes to load. 0 = 3, 1 = 1, 2 = 2
                2. 4 bits = Number of figures of displayed number
                                                     0 = Don’t care
                                                     1 = Don’t care
                                                     >=2 = Number
    """
    id = 0x9
    macro_name = "deciram"
    size = 4
    param_types = {
        0: {"name": "pointer?", "class": PointerLabelParam},
        1: {"name": "config", "class": HexByte},
    }
class InterpretDataStream(TextCommand):
    """
    0A = Interpret Data stream. Structure: [0A]
    see: http://hax.iimarck.us/files/scriptingcodes_eng.htm#Marke88
    """
    id = 0xA
    macro_name = "interpret_data"
    size = 1
class Play0thSound(TextCommand):
    "0B = Play sound 0x0000. Structure: [0B]"
    id = 0xB
    sound_num = 0
    macro_name = "sound0"
    size = 1
class LimitedIntrepretDataStream(TextCommand):
    """
    0C = Interpret Data stream. Structure: [0C][Number of codes to interpret]
    For every interpretation there is a“…“ written
    """
    id = 0xC
    macro_name = "limited_interpret_data"
    size = 2
    param_types = {
        0: {"name": "number of codes to interpret", "class": DecimalParam},
    }
class WaitForKeyDownDisplayArrow(ShowArrowsAndButtonWait):
    """
    0D = Wait for key down  display arrow. Structure: [0D]
    """
    id = 0xD
    macro_name = "waitbutton2"
    size = 1
class Play9thSound(Play0thSound):
    id = 0xE
    sound_num = 9
    macro_name = "sound0x09"
    size = 1
class Play1stSound(Play0thSound):
    id = 0xF
    sound_num = 1
    macro_name = "sound0x0F"
    size = 1
class Play2ndSound(Play0thSound):
    id = 0x10
    sound_num = 2
    macro_name = "sound0x02"
    size = 1
class Play10thSound(Play0thSound):
    id = 0x11
    sound_num = 10
    macro_name = "sound0x0A"
    size = 1
class Play45thSound(Play0thSound):
    id = 0x12
    sound_num = 0x2D
    macro_name = "sound0x2D"
    size = 1
class Play44thSound(Play0thSound):
    id = 0x13
    sound_num = 0x2C
    macro_name = "sound0x2C"
    size = 1
class DisplayByteFromRAMAt(TextCommand):
    """
    14 = Display MEMORY. Structure: [14][Byte]

    Byte:

      00 = MEMORY1
      01 = MEMORY2
      02 = MEMORY
      04 = TEMPMEMORY2
      05 = TEMPMEMORY1
    """
    id = 0x14
    macro_name = "show_byte_at"
    size = 2
    param_types = {
        1: {"name": "memory byte id", "class": DecimalParam},
    }
class WriteCurrentDay(TextCommand):
    "15 = Write current day. Structure: [15]"
    id = 0x15
    macro_name = "current_day"
    size = 1
class TextJump(TextCommand):
    "16 = 3byte pointer to new text follows. Structure: [16][2byte pointer][bank]"
    id = 0x16
    macro_name = "text_jump"
    size = 4
    param_types = {
        0: {"name": "text", "class": TextPointerLabelAfterBankParam},
    }
# this is needed because sometimes a script ends with $50 $50
class TextEndingCommand(TextCommand):
    id = 0x50
    macro_name = "db"
    override_byte_check = False
    size = 1
    end = True
    def to_asm(self):
        return "db $50"

text_command_classes = inspect.getmembers(sys.modules[__name__], \
                       lambda obj: inspect.isclass(obj) and \
                       issubclass(obj, TextCommand) and \
                       obj != TextCommand and obj != PokedexText)

# byte: [name, [param1 name, param1 type], [param2 name, param2 type], ...]
# 0x9E: ["verbosegiveitem", ["item", ItemLabelByte], ["quantity", SingleByteParam]],
pksv_crystal_more = {
    0x00: ["2call", ["pointer", ScriptPointerLabelParam]],
    0x01: ["3call", ["pointer", ScriptPointerLabelBeforeBank]],
    0x02: ["2ptcall", ["pointer", RAMAddressParam]],
    0x03: ["2jump", ["pointer", ScriptPointerLabelParam]],
    0x04: ["3jump", ["pointer", ScriptPointerLabelBeforeBank]],
    0x05: ["2ptjump", ["pointer", RAMAddressParam]],
    0x06: ["if equal", ["byte", SingleByteParam], ["pointer", ScriptPointerLabelParam]],
    0x07: ["if not equal", ["byte", SingleByteParam], ["pointer", ScriptPointerLabelParam]],
    0x08: ["iffalse", ["pointer", ScriptPointerLabelParam]],
    0x09: ["iftrue", ["pointer", ScriptPointerLabelParam]],
    0x0A: ["if greater than", ["byte", SingleByteParam], ["pointer", ScriptPointerLabelParam]],
    0x0B: ["if less than", ["byte", SingleByteParam], ["pointer", ScriptPointerLabelParam]],
    0x0C: ["jumpstd", ["predefined_script", MultiByteParam]],
    0x0D: ["callstd", ["predefined_script", MultiByteParam]],
    0x0E: ["3callasm", ["asm", AsmPointerParam]],
    0x0F: ["special", ["predefined_script", MultiByteParam]],
    0x10: ["2ptcallasm", ["asm", RAMAddressParam]],
    # should map_group/map_id be dealt with in some special way in the asm?
    0x11: ["checkmaptriggers", ["map_group", SingleByteParam], ["map_id", SingleByteParam]],
    0x12: ["domaptrigger", ["map_group", MapGroupParam], ["map_id", MapIdParam], ["trigger_id", SingleByteParam]],
    0x13: ["checktriggers"],
    0x14: ["dotrigger", ["trigger_id", SingleByteParam]],
    0x15: ["writebyte", ["value", SingleByteParam]],
    0x16: ["addvar", ["value", SingleByteParam]],
    0x17: ["random", ["input", SingleByteParam]],
    0x18: ["checkver"],
    0x19: ["copybytetovar", ["address", RAMAddressParam]],
    0x1A: ["copyvartobyte", ["address", RAMAddressParam]],
    0x1B: ["loadvar", ["address", RAMAddressParam], ["value", SingleByteParam]],
    0x1C: ["checkcode", ["variable_id", SingleByteParam]],
    0x1D: ["writevarcode", ["variable_id", SingleByteParam]],
    0x1E: ["writecode", ["variable_id", SingleByteParam], ["value", SingleByteParam]],
    0x1F: ["giveitem", ["item", ItemLabelByte], ["quantity", SingleByteParam]],
    0x20: ["takeitem", ["item", ItemLabelByte], ["quantity", DecimalParam]],
    0x21: ["checkitem", ["item", ItemLabelByte]],
    0x22: ["givemoney", ["account", SingleByteParam], ["money", MoneyByteParam]],
    0x23: ["takemoney", ["account", SingleByteParam], ["money", MoneyByteParam]],
    0x24: ["checkmoney", ["account", SingleByteParam], ["money", MoneyByteParam]],
    0x25: ["givecoins", ["coins", CoinByteParam]],
    0x26: ["takecoins", ["coins", CoinByteParam]],
    0x27: ["checkcoins", ["coins", CoinByteParam]],
    # 0x28-0x2A not from pksv
    0x28: ["addcellnum", ["person", SingleByteParam]],
    0x29: ["delcellnum", ["person", SingleByteParam]],
    0x2A: ["checkcellnum", ["person", SingleByteParam]],
    # back on track...
    0x2B: ["checktime", ["time", SingleByteParam]],
    0x2C: ["checkpoke", ["pkmn", PokemonParam]],
#0x2D: ["givepoke", ], .... see GivePoke class
    0x2E: ["giveegg", ["pkmn", PokemonParam], ["level", DecimalParam]],
    0x2F: ["givepokeitem", ["pointer", PointerParamToItemAndLetter]],
    0x30: ["checkpokeitem", ["pointer", PointerParamToItemAndLetter]], # not pksv
    0x31: ["checkevent", ["event_flag", EventFlagParam]],
    0x32: ["clearevent", ["event_flag", EventFlagParam]],
    0x33: ["setevent", ["event_flag", EventFlagParam]],
    0x34: ["checkflag", ["engine_flag", EngineFlagParam]],
    0x35: ["clearflag", ["engine_flag", EngineFlagParam]],
    0x36: ["setflag", ["engine_flag", EngineFlagParam]],
    0x37: ["wildon"],
    0x38: ["wildoff"],
    0x39: ["xycompare", ["pointer", MultiByteParam]],
    0x3A: ["warpmod", ["warp_id", SingleByteParam], ["map_group", MapGroupParam], ["map_id", MapIdParam]],
    0x3B: ["blackoutmod", ["map_group", MapGroupParam], ["map_id", MapIdParam]],
    0x3C: ["warp", ["map_group", MapGroupParam], ["map_id", MapIdParam], ["x", SingleByteParam], ["y", SingleByteParam]],
    0x3D: ["readmoney", ["account", SingleByteParam], ["memory", SingleByteParam]], # not pksv
    0x3E: ["readcoins", ["memory", SingleByteParam]], # not pksv
    0x3F: ["RAM2MEM", ["memory", SingleByteParam]], # not pksv
    0x40: ["pokenamemem", ["pokemon", PokemonParam], ["memory", SingleByteParam]], # not pksv
    0x41: ["itemtotext", ["item", ItemLabelByte], ["memory", SingleByteParam]],
    0x42: ["mapnametotext", ["memory", SingleByteParam]], # not pksv
    0x43: ["trainertotext", ["trainer_id", TrainerGroupParam], ["trainer_group", TrainerIdParam], ["memory", SingleByteParam]],
    0x44: ["stringtotext", ["text_pointer", EncodedTextLabelParam], ["memory", SingleByteParam]],
    0x45: ["itemnotify"],
    0x46: ["pocketisfull"],
    0x47: ["loadfont"],
    0x48: ["refreshscreen", ["dummy", SingleByteParam]],
    0x49: ["loadmovesprites"],
    0x4A: ["loadbytec1ce", ["byte", SingleByteParam]], # not pksv
    0x4B: ["3writetext", ["text_pointer", PointerLabelBeforeBank]],
    0x4C: ["2writetext", ["text_pointer", RawTextPointerLabelParam]],
    0x4D: ["repeattext", ["byte", SingleByteParam], ["byte", SingleByteParam]], # not pksv
    0x4E: ["yesorno"],
    0x4F: ["loadmenudata", ["data", MenuDataPointerParam]],
    0x50: ["writebackup"],
    0x51: ["jumptextfaceplayer", ["text_pointer", RawTextPointerLabelParam]],
    0x52: ["3jumptext", ["text_pointer", PointerLabelBeforeBank]],
    0x53: ["jumptext", ["text_pointer", RawTextPointerLabelParam]],
    0x54: ["closetext"],
    0x55: ["keeptextopen"],
    0x56: ["pokepic", ["pokemon", PokemonParam]],
    0x57: ["pokepicyesorno"],
    0x58: ["interpretmenu"],
    0x59: ["interpretmenu2"],
# not pksv
    0x5A: ["loadpikachudata"],
    0x5B: ["battlecheck"],
    0x5C: ["loadtrainerdata"],
# back to pksv..
    0x5D: ["loadpokedata", ["pokemon", PokemonParam], ["level", DecimalParam]],
    0x5E: ["loadtrainer", ["trainer_group", TrainerGroupParam], ["trainer_id", TrainerIdParam]],
    0x5F: ["startbattle"],
    0x60: ["returnafterbattle"],
    0x61: ["catchtutorial", ["byte", SingleByteParam]],
# not pksv
    0x62: ["trainertext", ["which_text", SingleByteParam]],
    0x63: ["trainerstatus", ["action", SingleByteParam]],
# back to pksv..
    0x64: ["winlosstext", ["win_text_pointer", TextPointerLabelParam], ["loss_text_pointer", TextPointerLabelParam]],
    0x65: ["scripttalkafter"], # not pksv
    0x66: ["talkaftercancel"],
    0x67: ["talkaftercheck"],
    0x68: ["setlasttalked", ["person", SingleByteParam]],
    0x69: ["applymovement", ["person", SingleByteParam], ["data", MovementPointerLabelParam]],
    0x6A: ["applymovement2", ["data", MovementPointerLabelParam]], # not pksv
    0x6B: ["faceplayer"],
    0x6C: ["faceperson", ["person1", SingleByteParam], ["person2", SingleByteParam]],
    0x6D: ["variablesprite", ["byte", SingleByteParam], ["sprite", SingleByteParam]],
    0x6E: ["disappear", ["person", SingleByteParam]], # hideperson
    0x6F: ["appear", ["person", SingleByteParam]], # showperson
    0x70: ["follow", ["person2", SingleByteParam], ["person1", SingleByteParam]],
    0x71: ["stopfollow"],
    0x72: ["moveperson", ["person", SingleByteParam], ["x", SingleByteParam], ["y", SingleByteParam]],
    0x73: ["writepersonxy", ["person", SingleByteParam]], # not pksv
    0x74: ["loademote", ["bubble", SingleByteParam]],
    0x75: ["showemote", ["bubble", SingleByteParam], ["person", SingleByteParam], ["time", DecimalParam]],
    0x76: ["spriteface", ["person", SingleByteParam], ["facing", SingleByteParam]],
    0x77: ["follownotexact", ["person2", SingleByteParam], ["person1", SingleByteParam]],
    0x78: ["earthquake", ["param", DecimalParam]],
    0x79: ["changemap", ["map_data_pointer", MapDataPointerParam]],
    0x7A: ["changeblock", ["x", SingleByteParam], ["y", SingleByteParam], ["block", SingleByteParam]],
    0x7B: ["reloadmap"],
    0x7C: ["reloadmappart"],
    0x7D: ["writecmdqueue", ["queue_pointer", MultiByteParam]],
    0x7E: ["delcmdqueue", ["byte", SingleByteParam]],
    0x7F: ["playmusic", ["music_pointer", MultiByteParam]],
    0x80: ["playrammusic"],
    0x81: ["musicfadeout", ["music", MultiByteParam], ["fadetime", SingleByteParam]],
    0x82: ["playmapmusic"],
    0x83: ["reloadmapmusic"],
    0x84: ["cry", ["cry_id", PokemonWordParam]],
    0x85: ["playsound", ["sound_pointer", MultiByteParam]],
    0x86: ["waitbutton"],
    0x87: ["warpsound"],
    0x88: ["specialsound"],
    0x89: ["passtoengine", ["data_pointer", PointerLabelBeforeBank]],
    0x8A: ["newloadmap", ["which_method", SingleByteParam]],
    0x8B: ["pause", ["length", DecimalParam]],
    0x8C: ["deactivatefacing", ["time", SingleByteParam]],
    0x8D: ["priorityjump", ["pointer", ScriptPointerLabelParam]],
    0x8E: ["warpcheck"],
    0x8F: ["ptpriorityjump", ["pointer", ScriptPointerLabelParam]],
    0x90: ["return"],
    0x91: ["end"],
    0x92: ["reloadandreturn", ["which_method", SingleByteParam]],
    0x93: ["resetfuncs"],
    0x94: ["pokemart", ["dialog_id", SingleByteParam], ["mart_id", MultiByteParam]], # maybe it should be a pokemark constant id/label?
    0x95: ["elevator", ["floor_list_pointer", PointerLabelParam]],
    0x96: ["trade", ["trade_id", SingleByteParam]],
    0x97: ["askforphonenumber", ["number", SingleByteParam]],
    0x98: ["phonecall", ["caller_name", RawTextPointerLabelParam]],
    0x99: ["hangup"],
    0x9A: ["describedecoration", ["byte", SingleByteParam]],
    0x9B: ["fruittree", ["tree_id", SingleByteParam]],
    0x9C: ["specialphonecall", ["call_id", MultiByteParam]],
    0x9D: ["checkphonecall"],
    0x9E: ["verbosegiveitem", ["item", ItemLabelByte], ["quantity", DecimalParam]],
    0x9F: ["verbosegiveitem2", ["item", ItemLabelByte], ["var", SingleByteParam]],
    0xA0: ["loadwilddata", ["flag", SingleByteParam], ["map_group", MapGroupParam], ["map_id", MapIdParam]],
    0xA1: ["halloffame"],
    0xA2: ["credits"],
    0xA3: ["warpfacing", ["facing", SingleByteParam], ["map_group", MapGroupParam], ["map_id", MapIdParam], ["x", SingleByteParam], ["y", SingleByteParam]],
    0xA4: ["storetext", ["memory", SingleByteParam]],
    0xA5: ["displaylocation", ["id", SingleByteParam], ["memory", SingleByteParam]],
    0xA6: ["trainerclassname", ["id", SingleByteParam], ["memory", SingleByteParam]],
    0xA7: ["name", ["type", SingleByteParam], ["id", SingleByteParam], ["mempry", SingleByteParam]],
    0xA8: ["wait", ["duration", DecimalParam]],
    0xA9: ["unknown0xa9"],
}
def create_command_classes(debug=False):
    """creates some classes for each command byte"""
    # don't forget to add any manually created script command classes
    # .. except for Warp, Signpost and some others that aren't found in scripts
    klasses = [GivePoke]
    for (byte, cmd) in pksv_crystal_more.items():
        cmd_name = cmd[0].replace(" ", "_")
        params = {"id": byte, "size": 1, "end": byte in pksv.pksv_crystal_more_enders, "macro_name": cmd_name}
        params["param_types"] = {}
        if len(cmd) > 1:
            param_types = cmd[1:]
            for (i, each) in enumerate(param_types):
                thing = {"name": each[0], "class": each[1]}
                params["param_types"][i] = thing
                if debug:
                    logging.debug("each is {0} and thing[class] is {1}".format(each, thing["class"]))
                params["size"] += thing["class"].size
        klass_name = cmd_name+"Command"
        klass = classobj(klass_name, (Command,), params)
        globals()[klass_name] = klass
        klasses.append(klass)
    # later an individual klass will be instantiated to handle something
    return klasses
command_classes = create_command_classes()


class BigEndianParam:
    """big-endian word"""
    size = 2
    should_be_decimal = False
    byte_type = "bigdw"

    def __init__(self, *args, **kwargs):
        self.prefix = '$'
        for (key, value) in kwargs.items():
            setattr(self, key, value)
        self.parse()

    def parse(self):
        self.bytes = rom.interval(self.address, 2, strings=False)
        self.parsed_number = self.bytes[0] * 0x100 + self.bytes[1]

    def to_asm(self):
        if not self.should_be_decimal:
            return self.prefix+"".join([("%.2x")%x for x in self.bytes])
        elif self.should_be_decimal:
            decimal = int("0x"+"".join([("%.2x")%x for x in self.bytes]), 16)
            return str(decimal)

    @staticmethod
    def from_asm(value):
        return value

class DecimalBigEndianParam(BigEndianParam):
    should_be_decimal = True

music_commands = {
    0xD0: ["octave 8"],
    0xD1: ["octave 7"],
    0xD2: ["octave 6"],
    0xD3: ["octave 5"],
    0xD4: ["octave 4"],
    0xD5: ["octave 3"],
    0xD6: ["octave 2"],
    0xD7: ["octave 1"],
    0xD8: ["notetype", ["note_length", SingleByteParam], ["intensity", SingleByteParam]], # no intensity on channel 4/8
    0xD9: ["forceoctave", ["octave", SingleByteParam]],
    0xDA: ["tempo", ["tempo", DecimalBigEndianParam]],
    0xDB: ["dutycycle", ["duty_cycle", SingleByteParam]],
    0xDC: ["intensity", ["intensity", SingleByteParam]],
    0xDD: ["soundinput", ["input", SingleByteParam]],
    0xDE: ["unknownmusic0xde", ["unknown", SingleByteParam]],
    0xDF: ["togglesfx"],
    0xE0: ["unknownmusic0xe0", ["unknown", SingleByteParam], ["unknown", SingleByteParam]],
    0xE1: ["vibrato", ["delay", SingleByteParam], ["extent", SingleByteParam]],
    0xE2: ["unknownmusic0xe2", ["unknown", SingleByteParam]],
    0xE3: ["togglenoise", ["id", SingleByteParam]], # no parameters on toggle off
    0xE4: ["panning", ["tracks", SingleByteParam]],
    0xE5: ["volume", ["volume", SingleByteParam]],
    0xE6: ["tone", ["tone", BigEndianParam]],
    0xE7: ["unknownmusic0xe7", ["unknown", SingleByteParam]],
    0xE8: ["unknownmusic0xe8", ["unknown", SingleByteParam]],
    0xE9: ["globaltempo", ["value", DecimalBigEndianParam]],
    0xEA: ["restartchannel", ["address", PointerLabelParam]],
    0xEB: ["newsong", ["id", DecimalBigEndianParam]],
    0xEC: ["sfxpriorityon"],
    0xED: ["sfxpriorityoff"],
    0xEE: ["unknownmusic0xee", ["address", PointerLabelParam]],
    0xEF: ["stereopanning", ["tracks", SingleByteParam]],
    0xF0: ["sfxtogglenoise", ["id", SingleByteParam]], # no parameters on toggle off
    0xF1: ["music0xf1"], # nothing
    0xF2: ["music0xf2"], # nothing
    0xF3: ["music0xf3"], # nothing
    0xF4: ["music0xf4"], # nothing
    0xF5: ["music0xf5"], # nothing
    0xF6: ["music0xf6"], # nothing
    0xF7: ["music0xf7"], # nothing
    0xF8: ["music0xf8"], # nothing
    0xF9: ["unknownmusic0xf9"],
    0xFA: ["setcondition", ["condition", SingleByteParam]],
    0xFB: ["jumpif", ["condition", SingleByteParam], ["address", PointerLabelParam]],
    0xFC: ["jumpchannel", ["address", PointerLabelParam]],
    0xFD: ["loopchannel", ["count", DecimalParam], ["address", PointerLabelParam]],
    0xFE: ["callchannel", ["address", PointerLabelParam]],
    0xFF: ["endchannel"],
}

music_command_enders = [
    "restartchannel",
    "newsong",
    "unknownmusic0xee",
    "jumpchannel",
    "endchannel",
]

def create_music_command_classes(debug=False):
    klasses = []
    for (byte, cmd) in music_commands.items():
        cmd_name = cmd[0].replace(" ", "_")
        params = {
            "id": byte,
            "size": 1,
            "end": cmd[0] in music_command_enders,
            "macro_name": cmd[0]
        }
        params["param_types"] = {}
        if len(cmd) > 1:
            param_types = cmd[1:]
            for (i, each) in enumerate(param_types):
                thing = {"name": each[0], "class": each[1]}
                params["param_types"][i] = thing
                if debug:
                    logging.debug("each is {0} and thing[class] is {1}".format(each, thing["class"]))
                params["size"] += thing["class"].size
        klass_name = cmd_name+"Command"
        klass = classobj(klass_name, (Command,), params)
        globals()[klass_name] = klass
        if klass.macro_name == "notetype":
            klass.allowed_lengths = [1, 2]
        elif klass.macro_name in ["togglenoise", "sfxtogglenoise"]:
            klass.allowed_lengths = [0, 1]
        klasses.append(klass)
    # later an individual klass will be instantiated to handle something
    return klasses

music_classes = create_music_command_classes()

class OctaveParam(DecimalParam):
    @staticmethod
    def from_asm(value):
        value = int(value)
        return hex(0xd8 - value).replace("0x", "$")

class OctaveCommand(Command):
    macro_name = "octave"
    size = 0
    end = False
    param_types = {
        0: {"name": "octave", "class": OctaveParam},
    }
    allowed_lengths = [1]
    override_byte_check = True

class ChannelCommand(Command):
    macro_name = "channel"
    size = 3
    override_byte_check = True
    param_types = {
        0: {"name": "id", "class": DecimalParam},
        1: {"name": "address", "class": PointerLabelParam},
    }


# pokered

class callchannel(Command):
    id = 0xFD
    macro_name = "callchannel"
    size = 3
    param_types = {
        0: {"name": "address", "class": PointerLabelParam},
    }

class loopchannel(Command):
    id = 0xFE
    macro_name = "loopchannel"
    size = 4
    param_types = {
        0: {"name": "count", "class": SingleByteParam},
        1: {"name": "address", "class": PointerLabelParam},
    }


effect_commands = {
    0x1: ['checkturn'],
    0x2: ['checkobedience'],
    0x3: ['usedmovetext'],
    0x4: ['doturn'],
    0x5: ['critical'],
    0x6: ['damagestats'],
    0x7: ['stab'],
    0x8: ['damagevariation'],
    0x9: ['checkhit'],
    0xa: ['effect0x0a'],
    0xb: ['effect0x0b'],
    0xc: ['effect0x0c'],
    0xd: ['resulttext'],
    0xe: ['checkfaint'],
    0xf: ['criticaltext'],
    0x10: ['supereffectivetext'],
    0x11: ['checkdestinybond'],
    0x12: ['buildopponentrage'],
    0x13: ['poisontarget'],
    0x14: ['sleeptarget'],
    0x15: ['draintarget'],
    0x16: ['eatdream'],
    0x17: ['burntarget'],
    0x18: ['freezetarget'],
    0x19: ['paralyzetarget'],
    0x1a: ['selfdestruct'],
    0x1b: ['mirrormove'],
    0x1c: ['statup'],
    0x1d: ['statdown'],
    0x1e: ['payday'],
    0x1f: ['conversion'],
    0x20: ['resetstats'],
    0x21: ['storeenergy'],
    0x22: ['unleashenergy'],
    0x23: ['forceswitch'],
    0x24: ['endloop'],
    0x25: ['flinchtarget'],
    0x26: ['ohko'],
    0x27: ['recoil'],
    0x28: ['mist'],
    0x29: ['focusenergy'],
    0x2a: ['confuse'],
    0x2b: ['confusetarget'],
    0x2c: ['heal'],
    0x2d: ['transform'],
    0x2e: ['screen'],
    0x2f: ['poison'],
    0x30: ['paralyze'],
    0x31: ['substitute'],
    0x32: ['rechargenextturn'],
    0x33: ['mimic'],
    0x34: ['metronome'],
    0x35: ['leechseed'],
    0x36: ['splash'],
    0x37: ['disable'],
    0x38: ['cleartext'],
    0x39: ['charge'],
    0x3a: ['checkcharge'],
    0x3b: ['traptarget'],
    0x3c: ['effect0x3c'],
    0x3d: ['rampage'],
    0x3e: ['checkrampage'],
    0x3f: ['constantdamage'],
    0x40: ['counter'],
    0x41: ['encore'],
    0x42: ['painsplit'],
    0x43: ['snore'],
    0x44: ['conversion2'],
    0x45: ['lockon'],
    0x46: ['sketch'],
    0x47: ['defrostopponent'],
    0x48: ['sleeptalk'],
    0x49: ['destinybond'],
    0x4a: ['spite'],
    0x4b: ['falseswipe'],
    0x4c: ['healbell'],
    0x4d: ['kingsrock'],
    0x4e: ['triplekick'],
    0x4f: ['kickcounter'],
    0x50: ['thief'],
    0x51: ['arenatrap'],
    0x52: ['nightmare'],
    0x53: ['defrost'],
    0x54: ['curse'],
    0x55: ['protect'],
    0x56: ['spikes'],
    0x57: ['foresight'],
    0x58: ['perishsong'],
    0x59: ['startsandstorm'],
    0x5a: ['endure'],
    0x5b: ['checkcurl'],
    0x5c: ['rolloutpower'],
    0x5d: ['effect0x5d'],
    0x5e: ['furycutter'],
    0x5f: ['attract'],
    0x60: ['happinesspower'],
    0x61: ['present'],
    0x62: ['damagecalc'],
    0x63: ['frustrationpower'],
    0x64: ['safeguard'],
    0x65: ['checksafeguard'],
    0x66: ['getmagnitude'],
    0x67: ['batonpass'],
    0x68: ['pursuit'],
    0x69: ['clearhazards'],
    0x6a: ['healmorn'],
    0x6b: ['healday'],
    0x6c: ['healnite'],
    0x6d: ['hiddenpower'],
    0x6e: ['startrain'],
    0x6f: ['startsun'],
    0x70: ['attackup'],
    0x71: ['defenseup'],
    0x72: ['speedup'],
    0x73: ['specialattackup'],
    0x74: ['specialdefenseup'],
    0x75: ['accuracyup'],
    0x76: ['evasionup'],
    0x77: ['attackup2'],
    0x78: ['defenseup2'],
    0x79: ['speedup2'],
    0x7a: ['specialattackup2'],
    0x7b: ['specialdefenseup2'],
    0x7c: ['accuracyup2'],
    0x7d: ['evasionup2'],
    0x7e: ['attackdown'],
    0x7f: ['defensedown'],
    0x80: ['speeddown'],
    0x81: ['specialattackdown'],
    0x82: ['specialdefensedown'],
    0x83: ['accuracydown'],
    0x84: ['evasiondown'],
    0x85: ['attackdown2'],
    0x86: ['defensedown2'],
    0x87: ['speeddown2'],
    0x88: ['specialattackdown2'],
    0x89: ['specialdefensedown2'],
    0x8a: ['accuracydown2'],
    0x8b: ['evasiondown2'],
    0x8c: ['statmessageuser'],
    0x8d: ['statmessagetarget'],
    0x8e: ['statupfailtext'],
    0x8f: ['statdownfailtext'],
    0x90: ['effectchance'],
    0x91: ['effect0x91'],
    0x92: ['effect0x92'],
    0x93: ['switchturn'],
    0x94: ['fakeout'],
    0x95: ['bellydrum'],
    0x96: ['psychup'],
    0x97: ['rage'],
    0x98: ['doubleflyingdamage'],
    0x99: ['doubleundergrounddamage'],
    0x9a: ['mirrorcoat'],
    0x9b: ['checkfuturesight'],
    0x9c: ['futuresight'],
    0x9d: ['doubleminimizedamage'],
    0x9e: ['skipsuncharge'],
    0x9f: ['thunderaccuracy'],
    0xa0: ['teleport'],
    0xa1: ['beatup'],
    0xa2: ['ragedamage'],
    0xa3: ['effect0xa3'],
    0xa4: ['allstatsup'],
    0xa5: ['effect0xa5'],
    0xa6: ['effect0xa6'],
    0xa7: ['effect0xa7'],
    0xa8: ['effect0xa8'],
    0xa9: ['clearmissdamage'],
    0xaa: ['movedelay'],
    0xab: ['hittarget'],
    0xac: ['tristatuschance'],
    0xad: ['supereffectivelooptext'],
    0xae: ['startloop'],
    0xaf: ['curl'],
    0xfe: ['endturn'],
    0xff: ['endmove'],
}

effect_command_enders = [0xFF,]

def create_effect_command_classes(debug=False):
    klasses = []
    for (byte, cmd) in effect_commands.items():
        cmd_name = cmd[0].replace(" ", "_")
        params = {
            "id": byte,
            "size": 1,
            "end": byte in effect_command_enders,
            "macro_name": cmd_name
        }
        params["param_types"] = {}
        if len(cmd) > 1:
            param_types = cmd[1:]
            for (i, each) in enumerate(param_types):
                thing = {"name": each[0], "class": each[1]}
                params["param_types"][i] = thing
                if debug:
                    logging.debug("each is {0} and thing[class] is {1}".format(each, thing["class"]))
                params["size"] += thing["class"].size
        klass_name = cmd_name+"Command"
        klass = classobj(klass_name, (Command,), params)
        globals()[klass_name] = klass
        klasses.append(klass)
    # later an individual klass will be instantiated to handle something
    return klasses

effect_classes = create_effect_command_classes()



def generate_macros(filename=None):
    if filename == None:
        filename = os.path.join(conf.path, "script_macros.asm")
    """generates all macros based on commands
    this is dumped into script_macros.asm"""
    output  = "; This file is generated by generate_macros.\n"
    for command in command_classes:
        output += "\n"
        #if command.macro_name[0].isdigit():
        #    output += "_"
        output += command.macro_name + ": MACRO\n"
        output += spacing + "db $%.2x\n"%(command.id)
        current_param = 1
        for (index, each) in command.param_types.items():
            if issubclass(each["class"], SingleByteParam):
                output += spacing + "db \\" + str(current_param) + "\n"
            elif issubclass(each["class"], MultiByteParam):
                output += spacing + "dw \\" + str(current_param) + "\n"
            current_param += 1
        output += spacing + "ENDM\n"

    fh = open(filename, "w")
    fh.write(output)
    fh.close()

    return output

# use this to keep track of commands without pksv names
pksv_no_names = {}
def pretty_print_pksv_no_names():
    """just some nice debugging output
    use this to keep track of commands without pksv names
    pksv_no_names is created in parse_script_engine_script_at"""
    for (command_byte, addresses) in pksv_no_names.items():
        if command_byte in pksv.pksv_crystal_unknowns:
            continue
        print hex(command_byte) + " appearing in these scripts: "
        for address in addresses:
            print "    " + hex(address)

recursive_scripts = set([])
def rec_parse_script_engine_script_at(address, origin=None, debug=True):
    """this is called in parse_script_engine_script_at for recursion
    when this works it should be flipped back to using the regular
    parser."""
    recursive_scripts.add((address, origin))
    return parse_script_engine_script_at(address, origin=origin, debug=debug)

def find_broken_recursive_scripts(output=False, debug=True):
    """well.. these at least have a chance of maybe being broken?"""
    for r in list(recursive_scripts):
        script = {}
        length = "not counted here"
        if is_script_already_parsed_at(r[0]):
            script = script_parse_table[r[0]]
            length = str(len(script))
        if len(script) > 20 or script == {}:
            logging.debug(
                "script at {address} from main script {scr} with length {length}"
                .format(
                    address=hex(r[0]),
                    scr=hex(r[1]),
                    length=length,
                )
            )
            if output:
                parse_script_engine_script_at(r[0], force=True, debug=True)


stop_points = [0x1aafa2,
               0x9f58f, # battle tower
               0x9f62f, # battle tower
              ]
class Script:
    base_label = "UnknownScript_"
    def __init__(self, *args, **kwargs):
        self.address = None
        self.commands = None
        if len(kwargs) == 0 and len(args) == 0:
            raise Exception("Script.__init__ must be given some arguments")
        # first positional argument is address
        if len(args) == 1:
            address = args[0]
            if type(address) == str:
                address = int(address, 16)
            elif type(address) != int:
                raise Exception("address must be an integer or string")
            self.address = address
        elif len(args) > 1:
            raise Exception("don't know what to do with second (or later) positional arguments")
        self.dependencies = None
        if "label" in kwargs.keys():
            label = kwargs["label"]
        else:
            label = None
        if not label:
            label = self.base_label + hex(self.address)
        self.label = Label(name=label, address=address, object=self)
        if "map_group" in kwargs.keys():
            self.map_group = kwargs["map_group"]
        if "map_id" in kwargs.keys():
            self.map_id = kwargs["map_id"]
        if "parent" in kwargs.keys():
            self.parent = kwargs["parent"]
        # parse the script at the address
        if "use_old_parse" in kwargs.keys() and kwargs["use_old_parse"] == True:
            self.old_parse(**kwargs)
        else:
            self.parse(self.address, **kwargs)

    def pksv_list(self):
        """shows a list of pksv names for each command in the script"""
        items = []
        if type(self.commands) == dict:
            for (id, command) in self.commands.items():
                if command["type"] in pksv.pksv_crystal:
                    items.append(pksv.pksv_crystal[command["type"]])
                else:
                    items.append(hex(command["type"]))
        else:
            for command in self.commands:
                items.append(command.macro_name)
        return items


    def to_pksv(self):
        """returns a string of pksv command names"""
        pksv = self.pksv_list()
        output = "script starting at: "+hex(self.address)+" .. "
        first = True
        for item in pksv:
            item = str(item)
            if first:
                output += item
                first = False
            else:
                output += ", "+item
        return output

    def show_pksv(self):
        """prints a list of pksv command names in this script"""
        logging.debug("to_pksv(): {0}".format(self.to_pksv()))

    def parse(self, start_address, force=False, map_group=None, map_id=None, force_top=True, origin=True, debug=False):
        """parses a script using the Command classes
        as an alternative to the old method using hard-coded commands

        force_top just means 'force the main script to get parsed, but not any subscripts'
        """
        global command_classes, rom, script_parse_table
        current_address = start_address
        if debug:
            logging.debug(
                "Script.parse address={address} map_group={map_group} map_id={map_id}"
                .format(
                    address=hex(self.address),
                    map_group=str(map_group),
                    map_id=str(map_id),
                )
            )
        if start_address in stop_points and force == False:
            if debug:
                logging.debug(
                    "script parsing is stopping at stop_point={stop_point} at map_group={map_group} map_id={map_id}"
                    .format(
                        stop_point=hex(start_address),
                        map_group=str(map_group),
                        map_id=str(map_id),
                    )
                )
            return None
        if start_address < 0x4000 and start_address not in [0x26ef, 0x114, 0x1108]:
            if debug:
                logging.debug("address is less than 0x4000.. address is {0}".format(hex(start_address)))
            sys.exit(1)
        if is_script_already_parsed_at(start_address) and not force and not force_top:
            raise Exception("this script has already been parsed before, please use that instance ("+hex(start_address)+")")

        # load up the rom if it hasn't been loaded already
        rom = load_rom()

        # in the event that the script parsing fails.. it would be nice to leave evidence
        script_parse_table[start_address:start_address+1] = "incomplete parse_script_with_command_classes"

        # start with a blank script
        commands = []

        # use this to control the while loop
        end = False

        # for each command found..
        while not end:
            # get the current scripting byte
            cur_byte = ord(rom[current_address])

            # reset the command class (last command was probably different)
            scripting_command_class = None

            # match the command id byte to a scripting command class like GivePoke
            for class_ in command_classes:
                if class_.id == cur_byte:
                    scripting_command_class = class_

            # no matching command found (not implemented yet)- just end this script
            # NOTE: might be better to raise an exception and end the program?
            if scripting_command_class == None:
                if debug:
                    logging.debug("parsing script; current_address is: {0}".format(hex(current_address)))
                current_address += 1
                asm_output = "\n".join([command.to_asm() for command in commands])
                end = True
                continue
                # maybe the program should exit with failure instead?
                #raise Exception("no command found? id: " + hex(cur_byte) + " at " + hex(current_address) + " asm is:\n" + asm_output)

            # create an instance of the command class and let it parse its parameter bytes
            #print "about to parse command(script@"+hex(start_address)+"): " + str(scripting_command_class.macro_name)
            cls = scripting_command_class(address=current_address, force=force, map_group=map_group, map_id=map_id, parent=self)

            #if self.debug:
            #    print cls.to_asm()

            # store it in this script object
            commands.append(cls)

            # certain commands will end the scripting engine
            end = cls.end

            # skip past the command's parameter bytes to go to the next command
            #current_address = cls.last_address + 1
            current_address += cls.size

        # last byte belonging to script is last byte of last command,
        # or the last byte of the last command's last parameter
        self.last_address = current_address

        # store the script in the global table/map thing
        script_parse_table[start_address:current_address] = self

        asm_output = "\n".join([command.to_asm() for command in commands])
        if debug:
            logging.debug("asm_output is: {0}".format(asm_output))

        # store the script
        self.commands = commands

        return commands

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        if self.dependencies != None and not recompute:
            global_dependencies.update(self.dependencies)
            return self.dependencies
        dependencies = []
        for command in self.commands:
            deps = command.get_dependencies(recompute=recompute, global_dependencies=global_dependencies)
            dependencies.extend(deps)
        self.dependencies = dependencies
        return dependencies

    def to_asm(self):
        asm_output = "".join([command.to_asm()+"\n" for command in self.commands])
        if asm_output[-1] == "\n":
            asm_output = asm_output[:-1]
        return asm_output

    def old_parse(self, *args, **kwargs):
        """included from old_parse_scripts"""

import old_parse_scripts
Script.old_parse = old_parse_scripts.old_parse

def parse_script_engine_script_at(address, map_group=None, map_id=None, force=False, debug=True, origin=True):
    if is_script_already_parsed_at(address) and not force:
        return script_parse_table[address]
    return Script(address, map_group=map_group, map_id=map_id, force=force, debug=debug, origin=origin)

def compare_script_parsing_methods(address):
    """
    compares the parsed scripts using the new method and the old method
    The new method is Script.parse, the old method is Script.old_parse.

    There are likely to be problems with the new script parser, the one
    that uses the command classes to parse bytes. To look for these
    problems, you can compare the output of one parsing method to the
    output of the other. When there's a difference, there is something
    worth correcting. Probably by each command's "macro_name" attribute.
    """
    rom = load_rom()
    separator = "################ compare_script_parsing_methods"
    # first do it the old way
    logging.debug(separator)
    logging.debug("parsing the script at {address} using the old method".format(address=hex(address)))
    oldscript = Script(address, debug=True, force=True, origin=True, use_old_parse=True)
    # and now the old way
    logging.debug(separator)
    logging.debug("parsing the script at {address} using the new method".format(address=hex(address)))
    newscript = Script(address, debug=True, force=True, origin=True)
    # let the comparison begin..
    errors = 0
    logging.debug("{0} COMPARISON RESULTS".format(separator))
    if not len(oldscript.commands.keys()) == len(newscript.commands):
        logging.debug("the two scripts don't have the same number of commands")
        errors += 1
    for (id, oldcommand) in oldscript.commands.items():
        newcommand = newscript.commands[id]
        oldcommand_pksv_name = pksv.pksv_crystal[oldcommand["type"]].replace(" ", "_")
        if oldcommand["start_address"] != newcommand.address:
            logging.debug(
                "The two address (command id={id}) do not match old={old} new={new}"
                .format(
                    id=id,
                    old=hex(oldcommand["start_address"]),
                    new=hex(newcommand.address),
                )
            )
            errors += 1
        if oldcommand_pksv_name != newcommand.macro_name:
            logging.debug(
                "The two commands (id={id}) do not have the same name old={old} new={new}"
                .format(
                    id=id,
                    old=oldcommand_pksv_name,
                    new=newcommand.macro_name,
                )
            )
            errors += 1
    logging.info("total comparison errors: {0}".format(errors))
    return oldscript, newscript


class Warp(Command):
    """only used outside of scripts"""
    size = warp_byte_size
    macro_name = "warp_def"
    param_types = {
        0: {"name": "y", "class": HexByte},
        1: {"name": "x", "class": HexByte},
        2: {"name": "warp_to", "class": DecimalParam},
        3: {"name": "map_bank", "class": MapGroupParam},
        4: {"name": "map_id", "class": MapIdParam},
    }
    override_byte_check = True

    def __init__(self, *args, **kwargs):
        self.id = kwargs["id"]
        script_parse_table[kwargs["address"] : kwargs["address"] + self.size] = self
        Command.__init__(self, *args, **kwargs)

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        return []

all_warps = []
def parse_warps(address, warp_count, bank=None, map_group=None, map_id=None, debug=True):
    warps = []
    current_address = address
    for each in range(warp_count):
        warp = Warp(address=current_address, id=each, bank=bank, map_group=map_group, map_id=map_id, debug=debug)
        current_address += warp_byte_size
        warps.append(warp)
    all_warps.extend(warps)
    return warps

class XYTrigger(Command):
    size = trigger_byte_size
    macro_name = "xy_trigger"
    param_types = {
        0: {"name": "number", "class": DecimalParam},
        1: {"name": "y", "class": HexByte},
        2: {"name": "x", "class": HexByte},
        3: {"name": "unknown1", "class": SingleByteParam},
        4: {"name": "script", "class": ScriptPointerLabelParam},
        5: {"name": "unknown2", "class": SingleByteParam},
        6: {"name": "unknown3", "class": SingleByteParam},
    }
    override_byte_check = True

    def __init__(self, *args, **kwargs):
        self.id = kwargs["id"]
        self.dependencies = None
        Command.__init__(self, *args, **kwargs)

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        dependencies = []
        if self.dependencies != None and not recompute:
            global_dependencies.update(self.dependencies)
            return self.dependencies
        thing = script_parse_table[self.params[4].parsed_address]
        if thing and thing != self.params[4]:
            dependencies.append(thing)
            global_dependencies.add(thing)
        self.dependencies = dependencies
        return dependencies

all_xy_triggers = []
def parse_xy_triggers(address, trigger_count, bank=None, map_group=None, map_id=None, debug=True):
    xy_triggers = []
    current_address = address
    for each in range(trigger_count):
        xy_trigger = XYTrigger(address=current_address, id=each, bank=bank, map_group=map_group, map_id=map_id, debug=debug)
        current_address += trigger_byte_size
        xy_triggers.append(xy_trigger)
    all_xy_triggers.extend(xy_triggers)
    return xy_triggers

def old_parse_xy_trigger_bytes(some_bytes, bank=None, map_group=None, map_id=None, debug=True):
    """parse some number of triggers from the data"""
    assert len(some_bytes) % trigger_byte_size == 0, "wrong number of bytes"
    triggers = []
    for bytes in helpers.grouper(some_bytes, count=trigger_byte_size):
        trigger_number = int(bytes[0], 16)
        y = int(bytes[1], 16)
        x = int(bytes[2], 16)
        unknown1 = int(bytes[3], 16) # XXX probably 00?
        script_ptr_byte1 = int(bytes[4], 16)
        script_ptr_byte2 = int(bytes[5], 16)
        script_ptr = script_ptr_byte1 + (script_ptr_byte2 << 8)
        script_address = None
        script = None
        if bank:
            script_address = pointers.calculate_pointer(script_ptr, bank)
            logging.debug(
                "parsing xy trigger byte scripts.. x={x} y={y}"
                .format(x=x, y=y)
            )
            script = parse_script_engine_script_at(script_address, map_group=map_group, map_id=map_id)

        triggers.append({
            "trigger_number": trigger_number,
            "y": y,
            "x": x,
            "unknown1": unknown1, # probably 00
            "script_ptr": script_ptr,
            "script_pointer": {"1": script_ptr_byte1, "2": script_ptr_byte2},
            "script_address": script_address,
            "script": script,
        })
    return triggers


class ItemFragment(Command):
    """used by ItemFragmentParam and PeopleEvent
    (for items placed on a map)"""
    size = 2
    macro_name = "db"
    base_label = "ItemFragment_"
    override_byte_check = True
    param_types = {
        0: {"name": "item", "class": ItemLabelByte},
        1: {"name": "quantity", "class": DecimalParam},
    }

    def __init__(self, address=None, bank=None, map_group=None, map_id=None, debug=False, label=None):
        if not is_valid_address(address):
            raise exceptions.AddressException(
                "ItemFragment must be given a valid address (but got {0})."
                .format(hex(address))
            )
        self.address = address
        self.last_address = address + self.size
        self.bank = bank
        if not label:
            label = self.base_label + hex(address)
        self.label = Label(name=label, address=address, object=self)
        self.map_group = map_group
        self.map_id = map_id
        self.debug = debug
        self.params = {}
        self.dependencies = None
        self.args = {"debug": debug, "map_group": map_group, "map_id": map_id, "bank": bank}
        script_parse_table[self.address : self.last_address] = self
        self.parse()


class ItemFragmentParam(PointerLabelParam):
    """used by PeopleEvent"""

    def parse(self):
        PointerLabelParam.parse(self)

        address = calculate_pointer_from_bytes_at(self.address, bank=self.bank)
        self.calculated_address = address

        itemfrag = ItemFragment(address=address, map_group=self.map_group, map_id=self.map_id, debug=self.debug)
        self.itemfrag = itemfrag

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        if self.dependencies != None and not recompute:
            global_dependencies.update(self.dependencies)
            return self.dependencies
        self.dependencies = [self.itemfrag].extend(self.itemfrag.get_dependencies(recompute=recompute, global_dependencies=global_dependencies))
        global_dependencies.add(self.itemfrag)
        return self.dependencies

class TrainerFragment(Command):
    """used by TrainerFragmentParam and PeopleEvent for trainer data

    Maybe this shouldn't be a Command. The output might sprawl
    over multiple lines, and maybe it should be commented in to_asm?

    [Event flag (2byte)][Trainer group][Trainer]
    [2byte pointer to Text when seen]
    [2byte pointer to text when trainer beaten]
    [2byte pointer to script when lost (0000=Blackout)]
    [2byte pointer to script if won/talked to again]

    The event flag tells the game later on if the trainer has been
    beaten already (set) or not (reset).

    03 = Nothing
    04 = Nothing
    05 = Nothing
    06 = Nothing
    """
    size = 12
    macro_name = "trainer_def"
    base_label = "Trainer_"
    override_byte_check = True
    param_types = {
        0: {"name": "event_flag", "class": EventFlagParam},
        1: {"name": "trainer_group", "class": TrainerGroupParam},
        2: {"name": "trainer_id", "class": TrainerIdParam},
        3: {"name": "text_when_seen", "class": TextPointerLabelParam},
        4: {"name": "text_when_trainer_beaten", "class": TextPointerLabelParam},
        5: {"name": "script_when_lost", "class": ScriptPointerLabelParam},
        6: {"name": "script_talk_again", "class": ScriptPointerLabelParam},
    }

    def __init__(self, *args, **kwargs):
        address = kwargs["address"]
        logging.debug("TrainerFragment address={0}".format(hex(address)))
        self.address = address
        self.last_address = self.address + self.size
        if not is_valid_address(address) or address in [0x26ef]:
            self.include_in_asm = False
            return
        script_parse_table[self.address : self.last_address] = self
        self.dependencies = None
        Command.__init__(self, *args, **kwargs)

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        deps = []
        if not is_valid_address(self.address):
            return deps
        if self.dependencies != None and not recompute:
            global_dependencies.update(self.dependencies)
            return self.dependencies
        #deps.append(self.params[3])
        deps.extend(self.params[3].get_dependencies(recompute=recompute, global_dependencies=global_dependencies))
        #deps.append(self.params[4])
        deps.extend(self.params[4].get_dependencies(recompute=recompute, global_dependencies=global_dependencies))
        #deps.append(self.params[5])
        deps.extend(self.params[5].get_dependencies(recompute=recompute, global_dependencies=global_dependencies))
        #deps.append(self.params[6])
        deps.extend(self.params[6].get_dependencies(recompute=recompute, global_dependencies=global_dependencies))
        self.dependencies = deps
        return deps

    def parse(self):
        Command.parse(self)

        # get the trainer group id
        trainer_group = self.params[1].byte

        # get the trainer id
        trainer_id = self.params[2].byte

        if not trainer_group in self.trainer_group_maximums.keys():
            self.trainer_group_maximums[trainer_group] = set([trainer_id])
        else:
            self.trainer_group_maximums[trainer_group].add(trainer_id)

        # give this object a possibly better label
        label = "Trainer"
        if ("uses_numeric_trainer_ids" in trainers.trainer_group_names[trainer_group].keys()) \
           or ("trainer_names" not in trainers.trainer_group_names[trainer_group].keys()):
            label += string.capwords(trainers.trainer_group_names[trainer_group]["constant"])
            if "trainer_names" in trainers.trainer_group_names[trainer_group].keys() \
               and len(trainers.trainer_group_names[trainer_group]["trainer_names"]) > 1:
                label += str(trainer_id)
        else:
            label += string.capwords(trainers.trainer_group_names[trainer_group]["constant"]) + \
                     string.capwords(trainers.trainer_group_names[trainer_group]["trainer_names"][trainer_id-1])

        label = label.replace("Gruntm", "GruntM").replace("Gruntf", "GruntF").replace("Lt_surge", "LtSurge")

        self.label = Label(name=label, address=self.address, object=self)

        # ---- give better labels to the objects created by TrainerFragment ----

        text_when_seen_text = script_parse_table[self.params[3].parsed_address]
        if text_when_seen_text != None:
            text_when_seen_label = Label(name=label + "WhenSeenText", address=text_when_seen_text.address, object=text_when_seen_text)
            text_when_seen_text.label = text_when_seen_label

        text_when_beaten_text = script_parse_table[self.params[4].parsed_address]
        if text_when_beaten_text != None:
            text_when_beaten_label = Label(name=label + "WhenBeatenText", address=text_when_beaten_text.address, object=text_when_beaten_text)
            text_when_beaten_text.label = text_when_beaten_label

        script_when_lost = script_parse_table[self.params[5].parsed_address]
        if script_when_lost != None:
            script_when_lost_label = Label(name=label + "WhenLostScript", address=script_when_lost.address, object=script_when_lost)
            script_when_lost.label = script_when_lost_label

        script_talk_again = script_parse_table[self.params[6].parsed_address]
        if script_talk_again != None:
            script_talk_again_label = Label(name=label + "WhenTalkScript", address=script_talk_again.address, object=script_talk_again)
            script_talk_again.label = script_talk_again_label

    def to_asm(self):
        xspacing = ""
        output = ""
        output += xspacing + "; event flag\n"
        output += xspacing + "dw $%.2x"%(self.params[0].parsed_number)
        output += "\n\n"+xspacing+"; trainer group && trainer id\n"
        output += xspacing + "db %s, %s" % (self.params[1].to_asm(), self.params[2].to_asm())
        output += "\n\n"+xspacing+"; text when seen\n"
        output += xspacing + "dw " + self.params[3].to_asm()
        output += "\n\n"+xspacing+"; text when trainer beaten\n"
        output += xspacing + "dw " + self.params[4].to_asm()
        output += "\n\n"+xspacing+"; script when lost\n"
        output += xspacing + "dw " + self.params[5].to_asm()
        output += "\n\n"+xspacing+"; script when talk again\n"
        output += xspacing + "dw " + self.params[6].to_asm()
        return output

class TrainerFragmentParam(PointerLabelParam):
    """used by PeopleEvent to point to trainer data"""
    def parse(self):
        address = calculate_pointer_from_bytes_at(self.address, bank=self.bank)
        self.calculated_address = address
        if address == 0x26ef:
            self.trainerfrag = None
        else:
            trainerfrag = TrainerFragment(address=address, map_group=self.map_group, map_id=self.map_id, debug=self.debug)
            self.trainerfrag = trainerfrag
        PointerLabelParam.parse(self)

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        deps = []
        if self.dependencies != None and not recompute:
            global_dependencies.update(self.dependencies)
            return self.dependencies
        if self.trainerfrag:
            global_dependencies.add(self.trainerfrag)
            deps.append(self.trainerfrag)
            deps.extend(self.trainerfrag.get_dependencies(recompute=recompute, global_dependencies=global_dependencies))
        self.dependencies = deps
        return deps

trainer_group_table = None
class TrainerGroupTable:
    """
    A list of pointers.

    This should probably be called TrainerGroupPointerTable.
    """

    def __init__(self, trainer_group_maximums=None, trainers=None, script_parse_table=None):
        self.trainer_group_maximums = trainer_group_maximums
        self.trainers = trainers
        self.script_parse_table = script_parse_table
        assert 0x43 in self.trainer_group_maximums.keys(), "TrainerGroupTable should only be created after all the trainers have been found"
        self.address = self.trainers.trainer_group_pointer_table_address
        self.bank = pointers.calculate_bank(self.trainers.trainer_group_pointer_table_address)
        self.label = Label(name="TrainerGroupPointerTable", address=self.address, object=self)
        self.size = None
        self.last_address = None
        self.dependencies = None
        self.headers = []
        self.parse()

        self.script_parse_table[self.address : self.last_address] = self

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        global_dependencies.update(self.headers)
        if recompute == True and self.dependencies != None and self.dependencies != []:
            return self.dependencies
        dependencies = copy(self.headers)
        for header in self.headers:
            dependencies.extend(header.get_dependencies(recompute=recompute, global_dependencies=global_dependencies))
        return dependencies

    def parse(self):
        size = 0
        for (key, kvalue) in self.trainers.trainer_group_names.items():
            # calculate the location of this trainer group header from its pointer
            pointer_bytes_location = kvalue["pointer_address"]
            parsed_address = calculate_pointer_from_bytes_at(pointer_bytes_location, bank=self.bank)
            self.trainers.trainer_group_names[key]["parsed_address"] = parsed_address

            # parse the trainer group header at this location
            name = kvalue["name"]
            trainer_group_header = TrainerGroupHeader(address=parsed_address, group_id=key, group_name=name, trainer_group_maximums=self.trainer_group_maximums)
            self.trainers.trainer_group_names[key]["header"] = trainer_group_header
            self.headers.append(trainer_group_header)

            # keep track of the size of this pointer table
            size += 2
        self.size = size
        self.last_address = self.address + self.size

    def to_asm(self):
        output = "".join([str("dw "+get_label_for(header.address)+"\n") for header in self.headers])
        return output

class TrainerGroupHeader:
    """
    A trainer group header is a repeating list of individual trainer headers.

    <Trainer Name> <0x50> <Data type> <Pokémon Data>+ <0xFF>

    Data type <0x00>: Pokémon Data is <Level> <Species>. Used by most trainers.
    Data type <0x01>: Pokémon Data is <Level> <Pokémon> <Move1> <Move2> <Move3> <Move4>. Used often for Gym Leaders.
    Data type <0x02>: Pokémon Data is <Level> <Pokémon> <Held Item>. Used mainly by Pokéfans.
    Data type <0x03>: Pokémon Data is <Level> <Pokémon> <Held Item> <Move1> <Move2> <Move3> <Move4>. Used by a few Cooltrainers.
    """

    def __init__(self, address=None, group_id=None, group_name=None, trainer_group_maximums=None):
        assert address!=None, "TrainerGroupHeader requires an address"
        assert group_id!=None, "TrainerGroupHeader requires a group_id"
        assert group_name!=None, "TrainerGroupHeader requires a group_name"

        self.trainer_group_maximums = trainer_group_maximums

        self.address = address
        self.group_id = group_id
        self.group_name = group_name
        self.dependencies = None
        self.individual_trainer_headers = []
        self.label = Label(name=group_name+"TrainerGroupHeader", address=self.address, object=self)
        self.parse()

        script_parse_table[address : self.last_address] = self

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        """
        TrainerGroupHeader has no dependencies.
        """
        # TODO: possibly include self.individual_trainer_headers
        if recompute or self.dependencies == None:
            self.dependencies = []
        return self.dependencies

    def parse(self):
        """
        how do i know when there's no more data for this header?
         do a global analysis of the rom and figure out the max ids
         this wont work for rom hacks of course
        see find_trainer_ids_from_scripts
        """
        size = 0
        current_address = self.address

        if self.group_id not in self.trainer_group_maximums.keys():
            self.size = 0
            self.last_address = current_address
            return

        # create an IndividualTrainerHeader for each id in range(min id, max id + 1)
        min_id = min(self.trainer_group_maximums[self.group_id])
        max_id = max(self.trainer_group_maximums[self.group_id])

        if self.group_id == 0x0C:
            # CAL appears a third time with third-stage evos (meganium, typhlosion, feraligatr)
            max_id += 1
        elif self.group_id == 0x29:
            # there's a missing supernerd :(
            max_id += 1
        elif self.group_id == 0x2D:
            # missing bikers
            max_id += 2
        elif self.group_id == 0x31:
            # missing jugglers
            max_id += 3
        elif self.group_id == 0x32:
            # blackbelt wai
            max_id += 1
        elif self.group_id == 0x3C:
            # kimono girl miki
            max_id += 1
        elif self.group_id == 0x3D:
            # twins lea & pia
            max_id += 1

        for trainer_id in range(min_id, max_id+1):
            trainer_header = TrainerHeader(address=current_address, trainer_group_id=self.group_id, trainer_id=trainer_id, parent=self)
            self.individual_trainer_headers.append(trainer_header)
            # current_address += trainer_header.size
            current_address = trainer_header.last_address
            size += trainer_header.size

        self.last_address = current_address
        self.size = size

    def to_asm(self):
        output = "\n\n".join(["; "+header.make_constant_name()+" ("+str(header.trainer_id)+") at "+hex(header.address)+"\n"+header.to_asm() for header in self.individual_trainer_headers])
        return output

class TrainerHeader:
    """
    <Trainer Name> <0x50> <Data type> <Pokémon Data>+ <0xFF>

    Data type <0x00>: Pokémon Data is <Level> <Species>. Used by most trainers.
    Data type <0x01>: Pokémon Data is <Level> <Pokémon> <Move1> <Move2> <Move3> <Move4>. Used often for Gym Leaders.
    Data type <0x02>: Pokémon Data is <Level> <Pokémon> <Held Item>. Used mainly by Pokéfans.
    Data type <0x03>: Pokémon Data is <Level> <Pokémon> <Held Item> <Move1> <Move2> <Move3> <Move4>. Used by a few Cooltrainers.
    """

    def __init__(self, address=None, trainer_group_id=None, trainer_id=None, parent=None):
        self.parent = parent
        self.address = address
        self.trainer_group_id = trainer_group_id
        self.trainer_id = trainer_id
        self.dependencies = []
        self.size = None
        self.last_address = None
        self.parse()
        self.label = Label(name=self.make_name(), address=self.address, object=self)
        # this shouldn't be added to script_parse_table because
        # TrainerGroupHeader covers its address range

    def make_name(self):
        """
        Must occur after parse() is called.
        Constructs a name based on self.parent.group_name and self.name.
        """
        if self.trainer_group_id in [0x14, 0x16, 0x17, 0x18, 0x19, 0x1B, 0x1C, 0x1D, 0x1E, 0x20, 0x21, 0x22, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2B, 0x2C, 0x2D, 0x2F, 0x30, 0x31, 0x32, 0x34, 0x35, 0x36, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x41]:
            return self.parent.group_name.upper() + "_" + self.name[:-1]
        else:
            return self.parent.group_name + "_" + str(self.trainer_id)

    def make_constant_name(self):
        if hasattr(self, "seed_constant_name"):
            seed = self.seed_constant_name
        else:
            seed = self.name

        if "?" in seed:
            if seed[-2].isdigit():
                x = 2
            else:
                x = 1
            seed = trainers.trainer_group_names[self.trainer_group_id]["name"]+"_"+seed[-x:]
        elif self.trainer_group_id == 0x1f and "EXECUTIVE" in seed:
            seed = "GRUNT_"+seed
        elif self.trainer_group_id == 0x2d and "BENNY" in seed.upper():
            seed = "BIKER_BENNY"
        elif self.trainer_group_id == 0x24 and "BENNY" in seed.upper():
            seed = "BUG_CATCHER_BENNY"

        return string.capwords(seed).\
               replace("@", "").\
               replace(" & ", "AND").\
               replace(" ", "").\
               replace(".", "_").\
               upper()

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        if recompute or self.dependencies == None:
            self.dependencies = []
        return self.dependencies

    def parse(self):
        address = self.address

        # figure out how many bytes until 0x50 "@"
        jump = how_many_until(chr(0x50), address, rom)

        # parse the "@" into the name
        self.name = parse_text_at(address, jump+1)

        # where is the next byte?
        current_address = address + jump + 1

        # figure out the pokemon data type
        self.data_type = ord(rom[current_address])

        current_address += 1

        # figure out which partymon parser to use for this trainer header
        party_mon_parser = None
        for monparser in trainer_party_mon_parsers:
            if monparser.id == self.data_type:
                party_mon_parser = monparser
                break

        if party_mon_parser == None:
            raise Exception("no trainer party mon parser found to parse data type " + hex(self.data_type))

        self.party_mons = party_mon_parser(address=current_address, group_id=self.trainer_group_id, trainer_id=self.trainer_id, parent=self)

        # let's have everything in trainer_party_mon_parsers handle the last $FF
        #self.size = self.party_mons.size + 1 + len(self.name)
        self.size = self.party_mons.last_address - self.address
        self.last_address = self.party_mons.last_address

    def to_asm(self):
        output = "db \""+self.name+"\"\n"
        output += "db $%.2x ; data type\n" % (self.data_type)
        output += self.party_mons.to_asm()
        output += "\n; last_address="+hex(self.last_address)+" size="+str(self.size)
        return output

class TrainerPartyMonParser:
    """
    Just a generic trainer party mon parser.
    Don't use this directly. Only use the child classes.
    """
    id = None
    dependencies = None
    param_types = None

    # could go either way on this one.. TrainerGroupHeader.parse would need to be changed
    # so as to not increase current_address by one after reading "data_type"
    override_byte_check = True

    def __init__(self, address=None, group_id=None, trainer_id=None, parent=None):
        self.address = address
        self.group_id = group_id
        self.trainer_id = trainer_id
        self.parent = parent
        self.args = {}
        self.mons = {}
        self.parse()

        # pick up the $FF at the end
        self.last_address += 1

    def parse(self):
        current_address = self.address
        pkmn = 0
        continuer = True
        while continuer:
            self.mons[pkmn] = {}
            i = 0
            for (key, param_type) in self.param_types.items():
                name = param_type["name"]
                klass = param_type["class"]
                # make an instance of this class, like SingleByteParam()
                # or ItemLabelByte.. by making an instance, obj.parse() is called
                obj = klass(address=current_address, name=name, parent=self, **dict([(k,v) for (k, v) in self.args.items() if k not in ["parent"]]))
                # save this for later
                self.mons[pkmn][i] = obj
                # increment our counters
                current_address += obj.size
                i += 1
            pkmn += 1
            if ord(rom[current_address]) == 0xFF:
                break
        self.last_address = current_address
        return True

    def to_asm(self):
        output = ""
        #output = "; " + ", ".join([param_type["name"] for (key, param_type) in self.param_types.items()]) + "\n"
        for mon in self.mons:
            output += "db " + ", ".join([param.to_asm() for (name, param) in self.mons[mon].items()])
            output += "\n"
        output += "db $ff ; end trainer party mons"
        return output

class TrainerPartyMonParser0(TrainerPartyMonParser):
    """
    Data type <0x00>: Pokémon Data is <Level> <Species>. Used by most trainers.
    """
    id = 0
    size = 2 + 1
    param_types = {
        0: {"name": "level", "class": DecimalParam},
        1: {"name": "species", "class": PokemonParam},
    }
class TrainerPartyMonParser1(TrainerPartyMonParser):
    """
    Data type <0x01>: Pokémon Data is <Level> <Pokémon> <Move1> <Move2> <Move3>
    <Move4>. Used often for Gym Leaders.
    """
    id = 1
    size = 6 + 1
    param_types = {
        0: {"name": "level", "class": DecimalParam},
        1: {"name": "species", "class": PokemonParam},
        2: {"name": "move1", "class": MoveParam},
        3: {"name": "move2", "class": MoveParam},
        4: {"name": "move3", "class": MoveParam},
        5: {"name": "move4", "class": MoveParam},
    }
class TrainerPartyMonParser2(TrainerPartyMonParser):
    """
    Data type <0x02>: Pokémon Data is <Level> <Pokémon> <Held Item>. Used mainly by Pokéfans.
    """
    id = 2
    size = 3 + 1
    param_types = {
        0: {"name": "level", "class": DecimalParam},
        1: {"name": "species", "class": PokemonParam},
        2: {"name": "item", "class": ItemLabelByte},
    }
class TrainerPartyMonParser3(TrainerPartyMonParser):
    """
    Data type <0x03>: Pokémon Data is <Level> <Pokémon> <Held Item> <Move1>
    <Move2> <Move3> <Move4>.
    Used by a few Cooltrainers.
    """
    id = 3
    size = 7 + 1
    param_types = {
        0: {"name": "level", "class": DecimalParam},
        1: {"name": "species", "class": PokemonParam},
        2: {"name": "item", "class": ItemLabelByte},
        3: {"name": "move1", "class": MoveParam},
        4: {"name": "move2", "class": MoveParam},
        5: {"name": "move3", "class": MoveParam},
        6: {"name": "move4", "class": MoveParam},
    }

trainer_party_mon_parsers = [TrainerPartyMonParser0, TrainerPartyMonParser1, TrainerPartyMonParser2, TrainerPartyMonParser3]

def find_trainer_ids_from_scripts(script_parse_table=None, trainer_group_maximums=None):
    """
    Looks through all scripts to find trainer group numbers and trainer numbers.

    This can be used with trainer_group_maximums to figure out the current number of
    trainers in each of the originating trainer groups.
    """
    total_unreferenced_trainers = 0

    # look at each possibly relevant script
    for item in script_parse_table.items():
        object = item[1]
        if isinstance(object, Script):
            check_script_has_trainer_data(object, trainer_group_maximums=trainer_group_maximums)

    # make a set of each list of trainer ids to avoid dupes
    # this will be used later in TrainerGroupTable
    for item in trainer_group_maximums.items():
        key = item[0]
        value = set(item[1])
        trainer_group_maximums[key] = value

def report_unreferenced_trainer_ids(trainer_group_maximums):
    """
    Reports on the number of unreferenced trainer ids in each group.

    This should be called after find_trainer_ids_from_scripts.

    These are trainer groups with "unused" trainer ids. The
    "find_trainer_ids_from_scripts" function analyzes each script in the game,
    and each map header in the game (because of code in TrainerFragment), and
    finds all references to trainers. But, if there are any trainers that are
    referenced in raw ASM, this method does not detect them. Each instance of a
    trainer reference is added to a global table called
    "trainer_group_maximums". Next, "find_trainer_ids_from_scripts" looks at
    the trainer IDs referenced for each group and takes the minimum number and
    the maximum number. To find whether or not there are any unused trainers,
    it takes the minimum and maximum ids and then sees which intermediate
    numbers are missing from the list of "referenced" trainer ids.
    """
    for item in trainer_group_maximums.items():
        key = item[0]
        value = item[1]

        # i'm curious: are there any missing trainer ids in this group?
        min_id = min(value)
        max_id = max(value)
        expectables = range(min_id, max_id+1)

        unreferenced = set()

        for expectable in expectables:
            if not expectable in value:
                unreferenced.add(expectable)

        if len(unreferenced) > 0:
            total_unreferenced_trainers += len(unreferenced)
            output = "trainer group "+hex(key)+" (\""+trainers.trainer_group_names[key]["name"]+"\")"
            output += " (min="+str(min_id)+", max="+str(max_id)+")"
            output += " has "+str(len(unreferenced))+" unreferenced trainer ids"
            output += ": " + str(unreferenced)
            logging.info(output)
    logging.info("total unreferenced trainers: {0}".format(total_unreferenced_trainers))

def trainer_group_report(trainer_group_maximums):
    """
    Reports how many trainer ids are used in each trainer group.
    """
    output = ""
    total = 0
    for trainer_group_id in trainer_group_maximums.keys():
        group_name = trainers.trainer_group_names[trainer_group_id]["name"]
        first_name = trainer_name_from_group(trainer_group_id).replace("\n", "")
        trainers = len(trainer_group_maximums[trainer_group_id])
        total += trainers
        output += "group "+hex(trainer_group_id)+":\n"
        output += "\tname: "+group_name+"\n"
        output += "\tfirst: "+first_name+"\n"
        output += "\ttrainer count:\t"+str(trainers)+"\n\n"
    output += "total trainers: " + str(total)
    return output

def check_script_has_trainer_data(script, trainer_group_maximums=None):
    """
    see find_trainer_ids_from_scripts
    """
    for command in script.commands:
        trainer_group = None
        trainer_id = None

        if command.id == 0x43:
            trainer_group = command.params[0].byte
            trainer_id = command.params[1].byte
        elif command.id == 0x5E:
            trainer_group = command.params[0].byte
            trainer_id = command.params[1].byte

        if trainer_group != None and trainer_id != None:
            if trainer_group in trainer_group_maximums.keys():
                trainer_group_maximums[trainer_group].add(trainer_id)
            else:
                trainer_group_maximums[trainer_group] = set([trainer_id])

def trainer_name_from_group(group_id, trainer_id=0):
    """This doesn't actually work for trainer_id > 0."""
    bank = pointers.calculate_bank(0x39999)
    ptr_address = 0x39999 + ((group_id - 1)*2)
    address = calculate_pointer_from_bytes_at(ptr_address, bank=bank)
    text = parse_text_at2(address, how_many_until(chr(0x50), address, rom))
    return text

def make_trainer_group_name_trainer_ids(trainer_group_table, debug=True):
    """
    Edits trainers.trainer_group_names and sets the trainer names.
    For instance, "AMY & MAY" becomes "AMY_AND_MAY1" and "AMY_AND_MAY2"

    This should only be used after TrainerGroupTable.parse has been called.
    """
    assert trainer_group_table != None, "TrainerGroupTable must be called before setting the trainer names"

    if debug:
        logging.info("starting to make trainer names and give ids to repeated trainer names")

    i = 1
    for header in trainer_group_table.headers:
        trainer_names = [] # (name, trainer_header)
        dupes = set()
        group_id = i
        group_name = header.group_name
        for trainer_header in header.individual_trainer_headers:
            if trainer_header.name in [x[0] for x in trainer_names]:
                dupes.add(trainer_header.name)
            trainer_names.append([trainer_header.name, trainer_header])

        # now fix trainers with duplicate names by appending an id
        if len(dupes) > 0:
            for dupe in dupes:
                culprits = [trainer_header for trainer_header in header.individual_trainer_headers if trainer_header.name == dupe]
                for (id, culprit) in enumerate(culprits):
                    culprit.seed_constant_name = culprit.name.replace("@", "") + str(id+1)
                    culprit.constant_name = culprit.make_constant_name()

        # now add the trainer names to trainers.trainer_group_names
        trainers.trainer_group_names[i]["trainer_names"] = [theader.make_constant_name() for theader in header.individual_trainer_headers]

        i += 1

    if debug:
        logging.info("done improving trainer names")


class SpriteParam(SingleByteParam):
    sprites = {
        0x1: 'SPRITE_CHRIS',
        0x2: 'SPRITE_CHRIS_BIKE',
        0x3: 'SPRITE_GAMEBOY_KID',
        0x4: 'SPRITE_SILVER',
        0x5: 'SPRITE_OAK',
        0x6: 'SPRITE_RED',
        0x7: 'SPRITE_BLUE',
        0x8: 'SPRITE_BILL',
        0x9: 'SPRITE_ELDER',
        0xa: 'SPRITE_JANINE',
        0xb: 'SPRITE_KURT',
        0xc: 'SPRITE_MOM',
        0xd: 'SPRITE_BLAINE',
        0xe: 'SPRITE_REDS_MOM',
        0xf: 'SPRITE_DAISY',
        0x10: 'SPRITE_ELM',
        0x11: 'SPRITE_WILL',
        0x12: 'SPRITE_FALKNER',
        0x13: 'SPRITE_WHITNEY',
        0x14: 'SPRITE_BUGSY',
        0x15: 'SPRITE_MORTY',
        0x16: 'SPRITE_CHUCK',
        0x17: 'SPRITE_JASMINE',
        0x18: 'SPRITE_PRYCE',
        0x19: 'SPRITE_CLAIR',
        0x1a: 'SPRITE_BROCK',
        0x1b: 'SPRITE_KAREN',
        0x1c: 'SPRITE_BRUNO',
        0x1d: 'SPRITE_MISTY',
        0x1e: 'SPRITE_LANCE',
        0x1f: 'SPRITE_SURGE',
        0x20: 'SPRITE_ERIKA',
        0x21: 'SPRITE_KOGA',
        0x22: 'SPRITE_SABRINA',
        0x23: 'SPRITE_COOLTRAINER_M',
        0x24: 'SPRITE_COOLTRAINER_F',
        0x25: 'SPRITE_BUG_CATCHER',
        0x26: 'SPRITE_TWIN',
        0x27: 'SPRITE_YOUNGSTER',
        0x28: 'SPRITE_LASS',
        0x29: 'SPRITE_TEACHER',
        0x2a: 'SPRITE_BUENA',
        0x2b: 'SPRITE_SUPER_NERD',
        0x2c: 'SPRITE_ROCKER',
        0x2d: 'SPRITE_POKEFAN_M',
        0x2e: 'SPRITE_POKEFAN_F',
        0x2f: 'SPRITE_GRAMPS',
        0x30: 'SPRITE_GRANNY',
        0x31: 'SPRITE_SWIMMER_GUY',
        0x32: 'SPRITE_SWIMMER_GIRL',
        0x33: 'SPRITE_BIG_SNORLAX',
        0x34: 'SPRITE_SURFING_PIKACHU',
        0x35: 'SPRITE_ROCKET',
        0x36: 'SPRITE_ROCKET_GIRL',
        0x37: 'SPRITE_NURSE',
        0x38: 'SPRITE_LINK_RECEPTIONIST',
        0x39: 'SPRITE_CLERK',
        0x3a: 'SPRITE_FISHER',
        0x3b: 'SPRITE_FISHING_GURU',
        0x3c: 'SPRITE_SCIENTIST',
        0x3d: 'SPRITE_KIMONO_GIRL',
        0x3e: 'SPRITE_SAGE',
        0x3f: 'SPRITE_UNUSED_GUY',
        0x40: 'SPRITE_GENTLEMAN',
        0x41: 'SPRITE_BLACK_BELT',
        0x42: 'SPRITE_RECEPTIONIST',
        0x43: 'SPRITE_OFFICER',
        0x44: 'SPRITE_CAL',
        0x45: 'SPRITE_SLOWPOKE',
        0x46: 'SPRITE_CAPTAIN',
        0x47: 'SPRITE_BIG_LAPRAS',
        0x48: 'SPRITE_GYM_GUY',
        0x49: 'SPRITE_SAILOR',
        0x4a: 'SPRITE_BIKER',
        0x4b: 'SPRITE_PHARMACIST',
        0x4c: 'SPRITE_MONSTER',
        0x4d: 'SPRITE_FAIRY',
        0x4e: 'SPRITE_BIRD',
        0x4f: 'SPRITE_DRAGON',
        0x50: 'SPRITE_BIG_ONIX',
        0x51: 'SPRITE_N64',
        0x52: 'SPRITE_SUDOWOODO',
        0x53: 'SPRITE_SURF',
        0x54: 'SPRITE_POKE_BALL',
        0x55: 'SPRITE_POKEDEX',
        0x56: 'SPRITE_PAPER',
        0x57: 'SPRITE_VIRTUAL_BOY',
        0x58: 'SPRITE_OLD_LINK_RECEPTIONIST',
        0x59: 'SPRITE_ROCK',
        0x5a: 'SPRITE_BOULDER',
        0x5b: 'SPRITE_SNES',
        0x5c: 'SPRITE_FAMICOM',
        0x5d: 'SPRITE_FRUIT_TREE',
        0x5e: 'SPRITE_GOLD_TROPHY',
        0x5f: 'SPRITE_SILVER_TROPHY',
        0x60: 'SPRITE_KRIS',
        0x61: 'SPRITE_KRIS_BIKE',
        0x62: 'SPRITE_KURT_OUTSIDE',
        0x63: 'SPRITE_SUICUNE',
        0x64: 'SPRITE_ENTEI',
        0x65: 'SPRITE_RAIKOU',
        0x66: 'SPRITE_STANDING_YOUNGSTER',
    }

    pokemon_sprites = {
        0x80: 'SPRITE_UNOWN',
        0x81: 'SPRITE_GEODUDE',
        0x82: 'SPRITE_GROWLITHE',
        0x83: 'SPRITE_WEEDLE',
        0x84: 'SPRITE_SHELLDER',
        0x85: 'SPRITE_ODDISH',
        0x86: 'SPRITE_GENGAR',
        0x87: 'SPRITE_ZUBAT',
        0x88: 'SPRITE_MAGIKARP',
        0x89: 'SPRITE_SQUIRTLE',
        0x8a: 'SPRITE_TOGEPI',
        0x8b: 'SPRITE_BUTTERFREE',
        0x8c: 'SPRITE_DIGLETT',
        0x8d: 'SPRITE_POLIWAG',
        0x8e: 'SPRITE_PIKACHU',
        0x8f: 'SPRITE_CLEFAIRY',
        0x90: 'SPRITE_CHARMANDER',
        0x91: 'SPRITE_JYNX',
        0x92: 'SPRITE_STARMIE',
        0x93: 'SPRITE_BULBASAUR',
        0x94: 'SPRITE_JIGGLYPUFF',
        0x95: 'SPRITE_GRIMER',
        0x96: 'SPRITE_EKANS',
        0x97: 'SPRITE_PARAS',
        0x98: 'SPRITE_TENTACOOL',
        0x99: 'SPRITE_TAUROS',
        0x9a: 'SPRITE_MACHOP',
        0x9b: 'SPRITE_VOLTORB',
        0x9c: 'SPRITE_LAPRAS',
        0x9d: 'SPRITE_RHYDON',
        0x9e: 'SPRITE_MOLTRES',
        0x9f: 'SPRITE_SNORLAX',
        0xa0: 'SPRITE_GYARADOS',
        0xa1: 'SPRITE_LUGIA',
        0xa2: 'SPRITE_HO_OH',
    }

    variable_sprites = {
        0xe0: 'SPRITE_DAYCARE_MON_1',
        0xe1: 'SPRITE_DAYCARE_MON_2',
        0xf0: 'SPRITE_VARS',
        0xf0: 'SPRITE_CONSOLE',
        0xf1: 'SPRITE_DOLL_1',
        0xf2: 'SPRITE_DOLL_2',
        0xf3: 'SPRITE_BIG_DOLL',
        0xf4: 'SPRITE_WEIRD_TREE',
        0xf5: 'SPRITE_OLIVINE_RIVAL',
        0xf6: 'SPRITE_AZALEA_ROCKET',
        0xf7: 'SPRITE_FUSCHIA_GYM_1',
        0xf8: 'SPRITE_FUSCHIA_GYM_2',
        0xf9: 'SPRITE_FUSCHIA_GYM_3',
        0xfa: 'SPRITE_FUSCHIA_GYM_4',
        0xfb: 'SPRITE_COPYCAT',
        0xfc: 'SPRITE_JANINE_IMPERSONATOR',
    }

    def to_asm(self):
        if self.byte in self.sprites.keys():
            return self.sprites[self.byte]
        if self.byte in self.pokemon_sprites.keys():
            return self.sprites[self.byte]
        if self.byte in self.variable_sprites.keys():
            return self.sprites[self.byte]
        return SingleByteParam.to_asm(self)



class PeopleEvent(Command):
    size = people_event_byte_size
    macro_name = "person_event"
    base_label = "PeopleEvent_"
    override_byte_check = True
    param_types = {
        0: {"name": "sprite", "class": SpriteParam},
        1: {"name": "y from top+4", "class": DecimalParam},
        2: {"name": "x from top+4", "class": DecimalParam},
        3: {"name": "facing", "class": HexByte},
        4: {"name": "movement", "class": HexByte},
        5: {"name": "clock_hour", "class": DecimalParam},
        6: {"name": "clock_daytime", "class": DecimalParam},
        7: {"name": "color_function", "class": HexByte},
        8: {"name": "sight_range", "class": DecimalParam},
        9: {"name": "pointer", "class": PointerLabelParam}, # or ScriptPointerLabelParam or ItemLabelParam
        10: {"name": "event flag", "class": EventFlagParam},
    }

    def xto_asm(self):
        output = "\n; person-event\n; picture, y, x, facing, movement, clock_hour, clock_daytime, color_function, sight_range\n"
        output += "db $%.2x, %d, %d, $%.2x, $%.2x, %d, %d, $%.2x, %d\n" % (self.params[0].byte, self.params[1].byte, self.params[2].byte, self.params[3].byte, self.params[4].byte, self.params[5].byte, self.params[6].byte, self.params[7].byte, self.params[8].byte)
        output += "; pointer\ndw %s\n" % (self.params[9].to_asm())
        output += "; event flag\ndw %s" % (self.params[10].to_asm())
        return output

    def __init__(self, address, id, bank=None, map_group=None, map_id=None, debug=False, label=None, force=False):
        if not is_valid_address(address):
            raise exceptions.AddressException(
                "PeopleEvent must be given a valid address (but got {0})."
                .format(hex(address))
            )
        self.address = address
        self.last_address = address + people_event_byte_size
        self.id = id
        self.bank = bank
        if not label:
            label = self.base_label + hex(address)
        self.label = Label(name=label, address=address, object=self)
        self.map_group = map_group
        self.map_id = map_id
        self.debug = debug
        self.force = force
        self.params = {}
        self.dependencies = None
        # PeopleEvent should probably not be in the global script_parse_table
        #script_parse_table[self.address : self.last_address] = self
        self.parse()

    def parse(self):
        address = self.address
        bank = self.bank

        color_function_byte = None
        lower_bits = None
        higher_bits = None
        is_regular_script = None
        is_give_item = None
        is_trainer = None

        self.params = {}
        current_address = self.address
        i = 0
        self.size = 1
        color_function_byte = None
        for (key, param_type) in self.param_types.items():
            if i == 9:
                if is_give_item:
                    name = "item_fragment_pointer"
                    klass = ItemFragmentParam
                elif is_regular_script:
                    name = "script_pointer"
                    klass = ScriptPointerLabelParam
                elif is_trainer:
                    name = "trainer"
                    #klass = MultiByteParam
                    klass = TrainerFragmentParam
                else:
                    name = "unknown"
                    klass = MultiByteParam
            else:
                name = param_type["name"]
                klass = param_type["class"]
            obj = klass(address=current_address, name=name, debug=self.debug, force=self.force, map_group=self.map_group, map_id=self.map_id, bank=self.bank)
            self.params[i] = obj
            if i == 7:
                color_function_byte = ord(rom[current_address])
                lower_bits = color_function_byte & 0xF
                higher_bits = color_function_byte >> 4
                is_regular_script = lower_bits == 00
                is_give_item = lower_bits == 01
                is_trainer = lower_bits == 02
            current_address += obj.size
            self.size += obj.size
            i += 1
        self.last_address = current_address
        self.is_trainer = is_trainer
        self.is_give_item = is_give_item
        self.is_regular_script = is_regular_script
        self.y = self.params[1].byte
        self.x = self.params[2].byte
        self.facing = self.params[3].byte
        self.movement = self.params[4].byte
        self.clock_hour = self.params[5].byte
        self.clock_daytime = self.params[6].byte
        self.color_function = self.params[7].byte
        self.sight_range = self.params[8].byte
        self.pointer = self.params[9].bytes
        self.event_flag = self.params[10].bytes
        return True


all_people_events = []
def parse_people_events(address, people_event_count, bank=None, map_group=None, map_id=None, debug=False, force=False):
    # people_event_byte_size
    people_events = []
    current_address = address
    id = 0
    for each in range(people_event_count):
        pevent = PeopleEvent(address=current_address, id=id, bank=bank, map_group=map_group, map_id=map_id, debug=debug, force=force)
        current_address += people_event_byte_size
        people_events.append(pevent)
        id += 1
    all_people_events.extend(people_events)
    return people_events

def old_parse_people_event_bytes(some_bytes, address=None, map_group=None, map_id=None, debug=True):
    """parse some number of people-events from the data
    see http://hax.iimarck.us/files/scriptingcodes_eng.htm#Scripthdr

    For example, map 1.1 (group 1 map 1) has four person-events.

        37 05 07 06 00 FF FF 00 00 02 40 FF FF
        3B 08 0C 05 01 FF FF 00 00 05 40 FF FF
        3A 07 06 06 00 FF FF A0 00 08 40 FF FF
        29 05 0B 06 00 FF FF 00 00 0B 40 FF FF
    """
    assert len(some_bytes) % people_event_byte_size == 0, "wrong number of bytes"

    # address is not actually required for this function to work...
    bank = None
    if address:
        bank = pointers.calculate_bank(address)

    people_events = []
    for bytes in helpers.grouper(some_bytes, count=people_event_byte_size):
        pict = int(bytes[0], 16)
        y = int(bytes[1], 16)    # y from top + 4
        x = int(bytes[2], 16)    # x from left + 4
        face = int(bytes[3], 16) # 0-4 for regular, 6-9 for static facing
        move = int(bytes[4], 16)
        clock_time_byte1 = int(bytes[5], 16)
        clock_time_byte2 = int(bytes[6], 16)
        color_function_byte = int(bytes[7], 16) # Color|Function
        trainer_sight_range = int(bytes[8], 16)

        lower_bits = color_function_byte & 0xF
        #lower_bits_high = lower_bits >> 2
        #lower_bits_low = lower_bits & 3
        higher_bits = color_function_byte >> 4
        #higher_bits_high = higher_bits >> 2
        #higher_bits_low = higher_bits & 3

        is_regular_script = lower_bits == 00
        # pointer points to script
        is_give_item = lower_bits == 01
        # pointer points to [Item no.][Amount]
        is_trainer = lower_bits == 02
        # pointer points to trainer header

        # goldmap called these next two bytes "text_block" and "text_bank"?
        script_pointer_byte1 = int(bytes[9], 16)
        script_pointer_byte2 = int(bytes[10], 16)
        script_pointer = script_pointer_byte1 + (script_pointer_byte2 << 8)
        # calculate the full address by assuming it's in the current bank
        # but what if it's not in the same bank?
        extra_portion = {}
        if bank:
            ptr_address = pointers.calculate_pointer(script_pointer, bank)
            if is_regular_script:
                logging.debug(
                    "parsing a person-script at x={x} y={y} address={address}"
                    .format(
                        x=(x-4),
                        y=(y-4),
                        address=hex(ptr_address),
                    )
                )
                script = parse_script_engine_script_at(ptr_address, map_group=map_group, map_id=map_id)
                extra_portion = {
                    "script_address": ptr_address,
                    "script": script,
                    "event_type": "script",
                }
            if is_give_item:
                logging.debug("not parsing give item event.. [item id][quantity]")
                extra_portion = {
                    "event_type": "give_item",
                    "give_item_data_address": ptr_address,
                    "item_id": ord(rom[ptr_address]),
                    "item_qty": ord(rom[ptr_address+1]),
                }
            if is_trainer:
                logging.debug(
                    "parsing a trainer (person-event) at x={x} y={y}"
                    .format(x=x, y=y)
                )
                parsed_trainer = parse_trainer_header_at(ptr_address, map_group=map_group, map_id=map_id)
                extra_portion = {
                    "event_type": "trainer",
                    "trainer_data_address": ptr_address,
                    "trainer_data": parsed_trainer,
                }

        # XXX not sure what's going on here
        # event flag (hidden if set)
        # note: FFFF for none
        when_byte = int(bytes[11], 16)
        hide = int(bytes[12], 16)

        event_flag_byte2 = int(bytes[11], 16)
        event_flag_byte1 = int(bytes[12], 16)
        event_flag = event_flag_byte1 + (event_flag_byte2 << 8)

        people_event = {
            "pict": pict,
            "y": y,                      # y from top + 4
            "x": x,                      # x from left + 4
            "face": face,                # 0-4 for regular, 6-9 for static facing
            "move": move,
            "clock_time": {"1": clock_time_byte1,
                           "2": clock_time_byte2},       # clock/time setting byte 1
            "color_function_byte": color_function_byte,  # Color|Function
            "trainer_sight_range": trainer_sight_range,  # trainer range of sight
            "script_pointer": {"1": script_pointer_byte1,
                               "2": script_pointer_byte2},

            #"text_block": text_block,   # script pointer byte 1
            #"text_bank": text_bank,     # script pointer byte 2
            "when_byte": when_byte,      # event flag (hidden if set)
            "hide": hide,                # note: FFFF for none

            "is_trainer": is_trainer,
            "is_regular_script": is_regular_script,
            "is_give_item": is_give_item,
        }
        people_event.update(extra_portion)
        people_events.append(people_event)
    return people_events


class SignpostRemoteBase:
    def __init__(self, address, bank=None, map_group=None, map_id=None, signpost=None, debug=False, label=None):
        self.address = address
        self.last_address = address + self.size
        script_parse_table[self.address : self.last_address] = self
        self.bank = bank
        self.map_group = map_group
        self.map_id = map_id
        self.signpost = signpost
        self.debug = debug
        self.params = []
        if not label:
            label = self.base_label + hex(address)
        self.label = Label(name=label, address=address, object=self)
        self.dependencies = None
        self.parse()

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        dependencies = []
        if self.dependencies != None and not recompute:
            global_dependencies.update(self.dependencies)
            return self.dependencies
        for p in self.params:
            deps = p.get_dependencies(recompute=recompute, global_dependencies=global_dependencies)
            dependencies.extend(deps)
        self.dependencies = dependencies
        return dependencies

    def to_asm(self):
        """very similar to Command.to_asm"""
        if len(self.params) == 0:
            return ""
        #output = ", ".join([p.to_asm() for p in self.params])
        output = ""
        for param in self.params:
            if issubclass(param.__class__, SingleByteParam):
                output += "db "
            else:
                output += "dw "
            output += param.to_asm() + "\n"
        return output


class SignpostRemoteScriptChunk(SignpostRemoteBase):
    """
    a signpost might point to [Event flag (2byte)][2byte pointer to script]
    """
    base_label = "SignpostRemoteScript_"
    size = 4

    def parse(self):
        address = self.address
        bank = self.bank

        #event_flag_byte1 = ord(rom[address])
        #event_flag_byte2 = ord(rom[address+1])
        event_flag = MultiByteParam(address=address, map_group=self.map_group, map_id=self.map_id, debug=self.debug)
        self.params.append(event_flag)

        #script_address = calculate_pointer_from_bytes_at(address+2, bank=bank)
        #script = parse_script_engine_script_at(script_address, map_group=self.map_group, map_id=self.map_id, debug=self.debug)
        script_param = ScriptPointerLabelParam(address=address+2, map_group=self.map_group, map_id=self.map_id, debug=self.debug, force=False)
        self.params.append(script_param)
        self.script = script_param.script
        self.signpost.remote_script = self.script

        #self.event_flag_bytes = [event_flag_byte1, event_flag_byte2]
        #self.script_address = script_address
        #self.script = script


class SignpostRemoteItemChunk(SignpostRemoteBase):
    """
    a signpost might point to [Event flag (2byte)][Item no.]
    """
    base_label = "SignpostRemoteItem_"
    size = 3

    def parse(self):
        address = self.address
        bank = self.bank

        event_flag = MultiByteParam(address=address, map_group=self.map_group, map_id=self.map_id, debug=self.debug)
        self.params.append(event_flag)

        item = ItemLabelByte(address=address+2)
        self.params.append(item)
        self.item = item


class SignpostRemoteUnknownChunk(SignpostRemoteBase):
    """
    a signpost might point to [Event flag (2byte)][??]
    """
    base_label = "SignpostRemoteUnknown_"
    size = 3

    def parse(self):
        address = self.address
        bank = self.bank

        event_flag = MultiByteParam(address=address, bank=self.bank, map_group=self.map_group, map_id=self.map_id, debug=self.debug)
        self.params.append(event_flag)

        byte = SingleByteParam(address=address+2)
        self.params.append(byte)


# this could potentially extend Command
# see how class Warp does this
class Signpost(Command):
    """parse some number of signposts from the data

    [Y position][X position][Function][Script pointer (2byte)]

    functions:
        00      Sign can be read from all directions
                script pointer to: script
        01      Sign can only be read from below
                script pointer to: script
        02      Sign can only be read from above
                script pointer to: script
        03      Sign can only be read from right
                script pointer to: script
        04      Sign can only be read from left
                script pointer to: script
        05      If event flag is set then pointer is interpreted
                script pointer to: [event flag (2byte)][2byte pointer to script]
        06      If event flag is not set then pointer is interpreted
                script pointer to: [event flag (2byte)][2byte pointer to script]
        07      If event flag is set then item is given
                script pointer to: [event flag (2byte)][Item no.]
        08      No Action
                script pointer to: [event flag (2byte)][??]
    """
    size = 5
    macro_name = "signpost"
    override_byte_check = True

    # preprocessor uses this
    param_types = {
        0: {"name": "y", "class": DecimalParam},
        1: {"name": "x", "class": DecimalParam},
        2: {"name": "function", "class": HexByte},
        3: {"name": "pointer", "class": PointerLabelParam},
    }

    def __init__(self, address, id, bank=None, map_group=None, map_id=None, debug=True, label=None):
        self.address = address
        self.id = id
        if label == None:
            label = "UnknownSignpost_"+str(map_group)+"Map"+str(map_id)+"_"+hex(address)
        self.label = Label(name=label, address=address, object=self)
        self.map_group = map_group
        self.map_id = map_id
        self.debug = debug
        self.bank = bank
        self.last_address = self.address + self.size
        self.y, self.x, self.func = None, None, None
        # Signpost should probably not be in the globals
        #script_parse_table[self.address : self.last_address] = self
        self.remotes = []
        self.params = []
        self.dependencies = None
        self.parse()

    def parse(self):
        """parse just one signpost"""
        address = self.address
        bank = self.bank
        self.last_address = self.address + self.size
        bytes = rom.interval(self.address, self.size) #, signpost_byte_size)

        self.y = int(bytes[0], 16)
        self.x = int(bytes[1], 16)
        self.func = int(bytes[2], 16)
        y, x, func = self.y, self.x, self.func

        # y
        self.params.append(DecimalParam(address=address, bank=self.bank, map_group=self.map_group, map_id=self.map_id, debug=self.debug))
        # x
        self.params.append(DecimalParam(address=address+1, bank=self.bank, map_group=self.map_group, map_id=self.map_id, debug=self.debug))
        # func
        self.params.append(HexByte(address=address+2, bank=self.bank, map_group=self.map_group, map_id=self.map_id, debug=self.debug))

        output = "******* parsing signpost "+str(self.id)+" at: "
        output += "x="+str(x)+" y="+str(y)+" on map_group="
        output += str(self.map_group)+" map_id="+str(self.map_id)

        if func in [0, 1, 2, 3, 4]:
            # signpost's script pointer points to a script
            script_ptr_byte1 = int(bytes[3], 16)
            script_ptr_byte2 = int(bytes[4], 16)
            script_pointer = script_ptr_byte1 + (script_ptr_byte2 << 8)

            script_address = pointers.calculate_pointer(script_pointer, bank)
            output += " script@"+hex(script_address)
            logging.debug(output)

            param = ScriptPointerLabelParam(address=self.address+3, map_group=self.map_group, map_id=self.map_id, debug=self.debug, force=False)
            self.params.append(param)
            param = script_parse_table[param.parsed_address]
            param.label = Label(address=param.address, object=param, name="Map"+map_names[self.map_group][self.map_id]["label"]+"Signpost"+str(self.id)+"Script")

            #self.script_address = script_address
            #self.script = script
        elif func in [5, 6]:
            # signpost's script pointer points to [event flag (2byte)][2byte pointer to script]
            ptr_byte1 = int(bytes[3], 16)
            ptr_byte2 = int(bytes[4], 16)
            pointer = ptr_byte1 + (ptr_byte2 << 8)
            address = pointers.calculate_pointer(pointer, bank)

            event_flag_byte1 = ord(rom[address])
            event_flag_byte2 = ord(rom[address+1])
            script_ptr_byte1 = ord(rom[address+2])
            script_ptr_byte2 = ord(rom[address+3])
            script_address = calculate_pointer_from_bytes_at(address+2, bank=bank)

            output += " remote_chunk@"+hex(address)+" remote_script@"+hex(script_address)
            logging.debug(output)

            r1 = SignpostRemoteScriptChunk(address, signpost=self, \
                   bank=self.bank, map_group=self.map_group, map_id=self.map_id, \
                   debug=self.debug)
            self.remotes.append(r1)

            # give a better label to the SignpostRemoteScriptChunk
            r1.label = Label(address=r1.address, object=r1, name="Map"+map_names[self.map_group][self.map_id]["label"]+"SignpostPtr"+str(self.id))

            mb = PointerLabelParam(address=self.address+3, map_group=self.map_group, map_id=self.map_id, debug=self.debug)
            self.params.append(mb)

            # update the remote script address
            param = script_parse_table[script_address]
            param.label = Label(address=param.address, object=param, name="Map"+map_names[self.map_group][self.map_id]["label"]+"Signpost"+str(self.id)+"Script")

        elif func == 7:
            # signpost's script pointer points to [event flag (2byte)][Item no.]
            ptr_byte1 = int(bytes[3], 16)
            ptr_byte2 = int(bytes[4], 16)
            pointer = ptr_byte1 + (ptr_byte2 << 8)
            address = pointers.calculate_pointer(pointer, bank)

            item_id         = ord(rom[address+2])
            output += " item_id="+str(item_id)
            logging.debug(output)

            r1 = SignpostRemoteItemChunk(address, signpost=self, \
                   bank=self.bank, map_group=self.map_group, map_id=self.map_id, \
                   debug=self.debug)
            self.remotes.append(r1)
            r1.label = Label(address=r1.address, object=r1, name="Map"+map_names[self.map_group][self.map_id]["label"]+"SignpostItem"+str(self.id))

            mb = PointerLabelParam(address=self.address+3, map_group=self.map_group, map_id=self.map_id, debug=self.debug)
            self.params.append(mb)

            #event_flag_byte1 = ord(rom[address])
            #event_flag_byte2 = ord(rom[address+1])
            #self.event_flag_bytes = [event_flag_byte1, event_flag_byte2]
            #self.item_id = item_id
        elif func == 8:
            # signpost's script pointer points to [event flag (2byte)][??]
            ptr_byte1 = int(bytes[3], 16)
            ptr_byte2 = int(bytes[4], 16)
            pointer = ptr_byte1 + (ptr_byte2 << 8)
            address = pointers.calculate_pointer(pointer, bank)

            output += " remote unknown chunk at="+hex(address)
            logging.debug(output)

            r1 = SignpostRemoteUnknownChunk(address, signpost=self, \
                   bank=self.bank, map_group=self.map_group, map_id=self.map_id, \
                   debug=self.debug)
            self.remotes.append(r1)

            mb = PointerLabelParam(address=self.address+3, map_group=self.map_group, map_id=self.map_id, debug=self.debug)
            self.params.append(mb)
        else:
            raise Exception("unknown signpost type byte="+hex(func) + " signpost@"+hex(self.address))

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        dependencies = []
        if self.dependencies != None and not recompute:
            global_dependencies.update(self.dependencies)
            return self.dependencies
        for p in self.params:
            dependencies.extend(p.get_dependencies(recompute=recompute, global_dependencies=global_dependencies))
        self.dependencies = dependencies
        return dependencies

    def to_asm(self):
        output = self.macro_name + " "
        if self.params == []:
            raise Exception("signpost has no params?")
        output += ", ".join([p.to_asm() for p in self.params])
        return output

all_signposts = []
def parse_signposts(address, signpost_count, bank=None, map_group=None, map_id=None, debug=True):
    if bank == None:
        raise Exception("signposts need to know their bank")
    signposts = []
    current_address = address
    id = 0
    for each in range(signpost_count):
        signpost = Signpost(current_address, id, bank=bank, map_group=map_group, map_id=map_id, debug=debug)
        current_address += signpost_byte_size # i think ??
        signposts.append(signpost)
        id += 1
    all_signposts.extend(signposts)
    return signposts


class LandmarkParam(SingleByteParam):
    landmarks = [
        'SPECIAL_MAP',

        # johto
        'NEW_BARK_TOWN',
        'ROUTE_29',
        'CHERRYGROVE_CITY',
        'ROUTE_30',
        'ROUTE_31',
        'VIOLET_CITY',
        'SPROUT_TOWER',
        'ROUTE_32',
        'RUINS_OF_ALPH',
        'UNION_CAVE',
        'ROUTE_33',
        'AZALEA_TOWN',
        'SLOWPOKE_WELL',
        'ILEX_FOREST',
        'ROUTE_34',
        'GOLDENROD_CITY',
        'RADIO_TOWER',
        'ROUTE_35',
        'NATIONAL_PARK',
        'ROUTE_36',
        'ROUTE_37',
        'ECRUTEAK_CITY',
        'TIN_TOWER',
        'BURNED_TOWER',
        'ROUTE_38',
        'ROUTE_39',
        'OLIVINE_CITY',
        'LIGHTHOUSE',
        'BATTLE_TOWER',
        'ROUTE_40',
        'WHIRL_ISLANDS',
        'ROUTE_41',
        'CIANWOOD_CITY',
        'ROUTE_42',
        'MT_MORTAR',
        'MAHOGANY_TOWN',
        'ROUTE_43',
        'LAKE_OF_RAGE',
        'ROUTE_44',
        'ICE_PATH',
        'BLACKTHORN_CITY',
        'DRAGONS_DEN',
        'ROUTE_45',
        'DARK_CAVE',
        'ROUTE_46',
        'SILVER_CAVE',

        # kanto
        'PALLET_TOWN',
        'ROUTE_1',
        'VIRIDIAN_CITY',
        'ROUTE_2',
        'PEWTER_CITY',
        'ROUTE_3',
        'MT_MOON',
        'ROUTE_4',
        'CERULEAN_CITY',
        'ROUTE_24',
        'ROUTE_25',
        'ROUTE_5',
        'UNDERGROUND',
        'ROUTE_6',
        'VERMILION_CITY',
        'DIGLETTS_CAVE',
        'ROUTE_7',
        'ROUTE_8',
        'ROUTE_9',
        'ROCK_TUNNEL',
        'ROUTE_10',
        'POWER_PLANT',
        'LAVENDER_TOWN',
        'LAV_RADIO_TOWER',
        'CELADON_CITY',
        'SAFFRON_CITY',
        'ROUTE_11',
        'ROUTE_12',
        'ROUTE_13',
        'ROUTE_14',
        'ROUTE_15',
        'ROUTE_16',
        'ROUTE_17',
        'ROUTE_18',
        'FUCHSIA_CITY',
        'ROUTE_19',
        'ROUTE_20',
        'SEAFOAM_ISLANDS',
        'CINNABAR_ISLAND',
        'ROUTE_21',
        'ROUTE_22',
        'VICTORY_ROAD',
        'ROUTE_23',
        'INDIGO_PLATEAU',
        'ROUTE_26',
        'ROUTE_27',
        'TOHJO_FALLS',
        'ROUTE_28',
        'FAST_SHIP',
    ]

    def to_asm(self):
        if self.byte < len(self.landmarks):
            return self.landmarks[self.byte]
        return SingleByteParam.to_asm(self)


class SongParam(SingleByteParam):
    def to_asm(self):
        if self.byte < len(song_names):
            return 'MUSIC_' + song_names[self.byte].upper().replace(' ','_')
        return SingleByteParam.to_asm(self)


class TimeOfDayParam(DecimalParam):
    times = ['MORN', 'DAY', 'NITE', 'DARKNESS']
    def to_asm(self):
        if self.byte < len(self.times):
            return self.times[self.byte]
        return DecimalParam.to_asm(self)


class MapHeader:
    base_label = "MapHeader_"

    def __init__(self, address, map_group=None, map_id=None, debug=True, label=None, bank=0x25):
        logging.debug(
            "creating a MapHeader at {address} map_group={map_group} map_id={map_id}"
            .format(address=hex(address), map_group=map_group, map_id=map_id)
        )
        self.address = address
        self.map_group = map_group
        self.map_id = map_id
        self.bank = bank
        self.debug = debug
        self.dependencies = None
        label = self.make_label()
        self.label = Label(name=label, address=address, object=self)
        self.last_address = address + 9
        script_parse_table[address : self.last_address] = self
        self.parse()

    def make_label(self):
        return map_names[self.map_group][self.map_id]["label"] + "_MapHeader"

    def parse(self):
        address = self.address
        logging.debug("parsing a MapHeader at {0}".format(hex(address)))
        self.bank = HexByte(address=address)
        self.tileset = HexByte(address=address+1)
        self.permission = DecimalParam(address=address+2)
        self.second_map_header_address = pointers.calculate_pointer(ord(rom[address+3])+(ord(rom[address+4])<<8), self.bank.byte)
        # TODO: is the bank really supposed to be 0x25 all the time ??
        self.second_map_header = SecondMapHeader(self.second_map_header_address, map_group=self.map_group, map_id=self.map_id, debug=self.debug)
        all_second_map_headers.append(self.second_map_header)
        self.location_on_world_map = LandmarkParam(address=address+5)
        self.music = SongParam(address=address+6)
        self.time_of_day = TimeOfDayParam(address=address+7)
        self.fishing_group = DecimalParam(address=address+8)

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        if self.dependencies != None and not recompute:
            global_dependencies.update(self.dependencies)
            return self.dependencies
        dependencies = [self.second_map_header]
        global_dependencies.add(self.second_map_header)
        dependencies.append(self.second_map_header.get_dependencies(recompute=recompute, global_dependencies=global_dependencies))
        self.dependencies = dependencies
        return dependencies

    def to_asm(self):
        output  = "; bank, tileset, permission\n"
        output += "db " + ", ".join(["BANK(" + self.second_map_header.label.name + ")", self.tileset.to_asm(), self.permission.to_asm()])
        output += "\n\n; second map header\n"
        output += "dw " + PointerLabelParam(address=self.address+3).to_asm() # TODO: should we include bank=self.bank.byte ??
        output += "\n\n; location on world map, music, time of day, fishing group\n"
        output += "db " + ", ".join([self.location_on_world_map.to_asm(), self.music.to_asm(), self.time_of_day.to_asm(), self.fishing_group.to_asm()])
        return output

def parse_map_header_at(address, map_group=None, map_id=None, all_map_headers=None, debug=True):
    """parses an arbitrary map header at some address"""
    logging.debug("parsing a map header at {0}".format(hex(address)))
    map_header = MapHeader(address, map_group=map_group, map_id=map_id, debug=debug)
    all_map_headers.append(map_header)
    return map_header

def get_direction(connection_byte, connection_id):
    """
    Given a connection byte and a connection id, which direction is this
    connection?

    example:
      The 0th connection of $5 is SOUTH and the 1st connection is
      EAST.
    """
    connection_options = [0b1000, 0b0100, 0b0010, 0b0001]
    results = ["NORTH", "SOUTH", "WEST", "EAST"]

    for option in connection_options:
        if (option & connection_byte) == 0:
            results[connection_options.index(option)] = ""

    # prune results
    while "" in results:
        results.remove("")

    return results[connection_id]

class SecondMapHeader:
    base_label = "SecondMapHeader_"

    def __init__(self, address, map_group=None, map_id=None, debug=True, bank=None, label=None):
        logging.debug("creating a SecondMapHeader at {0}".format(hex(address)))
        self.address = address
        self.map_group = map_group
        self.map_id = map_id
        self.debug = debug
        self.bank = bank
        self.dependencies = None
        label = self.make_label()
        self.label = Label(name=label, address=address, object=self)

        # the minimum number of bytes is 12
        self.last_address = address+12
        self.size = 12

        script_parse_table[address : self.last_address] = self
        self.parse()

    def make_label(self):
        return map_names[self.map_group][self.map_id]["label"] + "_SecondMapHeader"

    def parse(self):
        address = self.address
        bytes = rom.interval(address, second_map_header_byte_size, strings=False)
        size = second_map_header_byte_size

        # for later
        self.connections = []

        self.border_block = HexByte(address=address)
        self.height = DecimalParam(address=address+1)
        self.width  = DecimalParam(address=address+2)

        # bank appears first
        ###self.blockdata_address = PointerLabelBeforeBank(address+3)
        self.blockdata_address = calculate_pointer_from_bytes_at(address+3, bank=True)
        xyz = script_parse_table[self.blockdata_address]
        if xyz == None:
            self.blockdata = MapBlockData(self.blockdata_address, map_group=self.map_group, map_id=self.map_id, debug=self.debug, width=self.width, height=self.height)
        else:
            self.blockdata = xyz

        # bank appears first
        ###self.script_address = PointerLabelBeforeBank(address+6)
        self.script_header_address = calculate_pointer_from_bytes_at(address+6, bank=True)
        self.script_header = MapScriptHeader(self.script_header_address, map_group=self.map_group, map_id=self.map_id, debug=self.debug)
        all_map_script_headers.append(self.script_header)

        self.event_bank = ord(rom[address+6])
        self.event_header_address = calculate_pointer_from_bytes_at(address+9, bank=ord(rom[address+6]))
        self.event_header = MapEventHeader(self.event_header_address, map_group=self.map_group, map_id=self.map_id, debug=self.debug)
        self.connection_byte = DecimalParam(address=address+11)
        all_map_event_headers.append(self.event_header)

        self.size = size

        if self.connection_byte == 0:
            return True

        current_address = address+12

        # short alias
        cb    = self.connection_byte.byte

        # east = 1, west = 2, south = 4, north = 8 (or'd together)
        east  = ((cb & 0x1) != 0)
        west  = ((cb & 0x2) != 0)
        south = ((cb & 0x4) != 0)
        north = ((cb & 0x8) != 0)
        directions = [east, west, south, north]
        connection_count = directions.count(True)

        for connection in range(0, connection_count):
            direction = get_direction(self.connection_byte.byte, connection)
            connection = Connection(current_address, direction=direction, map_group=self.map_group, map_id=self.map_id, debug=self.debug, smh=self)
            self.connections.append(connection)

            # 12 bytes each?
            current_address += connection.size

        self.last_address = current_address

        return True

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        if self.dependencies != None and not recompute:
            global_dependencies.update(self.dependencies)
            return self.dependencies
        dependencies = [self.script_header, self.event_header, self.blockdata]
        global_dependencies.update(dependencies)
        dependencies.append(self.script_header.get_dependencies(recompute=recompute, global_dependencies=global_dependencies))
        dependencies.append(self.event_header.get_dependencies(recompute=recompute, global_dependencies=global_dependencies))
        self.dependencies = dependencies
        return dependencies

    def to_asm(self):
        self_constant_label = get_map_constant_label(map_group=self.map_group, map_id=self.map_id, map_internal_ids=self.map_internal_ids)
        output = "; border block\n"
        output += "db " + self.border_block.to_asm() + "\n\n"
        output += "; height, width\n"
        output += "db " + self_constant_label + "_HEIGHT, " + self_constant_label + "_WIDTH\n\n"
        output += "; blockdata (bank-then-pointer)\n"
        thing = ScriptPointerLabelBeforeBank(address=self.address+3, map_group=self.map_group, map_id=self.map_id, debug=self.debug).to_asm()
        output += "dbw " + thing.split(", ")[0] + ", "+thing.split(", ")[1] + "\n\n"
        output += "; script header (bank-then-pointer)\n"
        thing = ScriptPointerLabelBeforeBank(address=self.address+6, map_group=self.map_group, map_id=self.map_id, debug=self.debug).to_asm()
        output += "dbw " + thing.split(", ")[0] + ", " + thing.split(", ")[1] + "\n\n"
        output += "; map event header (bank-then-pointer)\n"
        output += "dw " + PointerLabelParam(address=self.address+9, bank=self.event_bank, map_group=self.map_group, map_id=self.map_id, debug=self.debug).to_asm() + "\n\n"

        output += "; connections\n"
        dir_results = []
        connection_options = [0b1000, 0b0100, 0b0010, 0b0001]
        dirs = ["NORTH", "SOUTH", "WEST", "EAST"]
        for (id, each) in enumerate(dirs):
            if ((connection_options[id] & self.connection_byte.byte) != 0):
                dir_results.append(each)
        output += "db " + " | ".join(dir_results)
        if len(dir_results) == 0:
            output += "0"

        if self.connection_byte.byte == 0 or len(dir_results) == 0:
            return output
        else:
            output += "\n\n"

        connections = "\n\n".join([connection.to_asm() for connection in self.connections])
        output += connections

        return output

strip_pointer_data = []
strip_destination_data = []
connections = []
wrong_norths = []
wrong_easts = []
wrong_souths = []
wrong_wests = []

class Connection:
    size = 12

    def __init__(self, address, direction=None, map_group=None, map_id=None, debug=True, smh=None):
        self.address = address
        self.direction = direction.lower()
        self.map_group = map_group
        self.map_id = map_id
        self.debug = debug
        self.smh = smh
        self.last_address = address + self.size
        connections.append(self)

        self.parse()

    def parse(self):
        current_address = self.address

        is_vertical   = ((self.direction == "north") or (self.direction == "south"))
        is_horizontal = ((self.direction == "east") or (self.direction == "west"))

        connected_map_group_id = ord(rom[current_address])
        self.connected_map_group_id = connected_map_group_id
        current_address += 1

        connected_map_id = ord(rom[current_address])
        self.connected_map_id = connected_map_id
        current_address += 1

        # window (use JohtoMap's calculation, not this)
        #   up: C701h + height_of_connected_map * (width_of_connected_map + 6)
        #   left: C706h + 2 * width_of_connected_map
        #   down/right: C707h + width_of_connected_map
        #
        # 2 bytes (flipped) - X position of starting point for intermediate
        # tiles (scrolls through connected map line-by-line. this way you can
        # change Y position also)
        #
        # According to JohtoMap, the calculation for tile data pointer is:
        #   int p = otherMap.tileDataLocation;
        #   int h = (otherMap.width - otherMap.height)
        #   if (h > 0)
        #       p += (h * otherMap.height) + (otherMap.height * 3) + (otherMap.height + 3)
        #   else
        #       p += (otherMap.height * otherMap.width) - (otherMap.width * 3);
        #   c.tileDataPointer = gb.Get2BytePointer(p);
        #
        # tauwasser calls this "connection strip pointer"
        tile_data_pointer = ord(rom[current_address]) + (ord(rom[current_address+1]) << 8)
        strip_pointer = tile_data_pointer
        self.strip_pointer = tile_data_pointer
        current_address += 2

        # 10:19 <comet> memoryotherpointer is <comet> what johtomap calls OMDL (in ram where the tiles start getting pulled from the other map)
        memory_other_pointer = ord(rom[current_address]) + (ord(rom[current_address+1]) << 8)
        # 10:42 <comet> it would be a good idea to rename otherpointer strippointer or striploc
        # 10:42 <comet> since thats more accurate
        # 11:05 <comet> Above: C803h + xoffset
        # 11:05 <comet> Below: C803h + (m.height + 3) * (m.width + 6) + xoffset
        # 11:05 <comet> Left: C800h + (m.width + 6) * (yoffset + 3)
        # 11:05 <comet> Right: C7FDh + (m.width + 6) * (yoffset + 4)
        #
        # tauwasser calls this "connection strip destination" and lin calls this "memoryOtherPointer"
        #   Points to the upper left block of the connection strip
        #   (The bank the Blockdata is in, is loaded out of the Mapheader of the connected Map.)
        #   The connection strip is always 3 Blocks high resp. wide
        #   (depending on the connection's direction)
        strip_destination = memory_other_pointer
        self.strip_destination = memory_other_pointer
        current_address += 2

        # length of the connection strip in blocks
        connection_strip_length = ord(rom[current_address])
        current_address += 1
        connected_map_width     = ord(rom[current_address])
        current_address += 1

        self.connection_strip_length = connection_strip_length
        self.connected_map_width     = connected_map_width

        y_position_after_map_change = ord(rom[current_address])
        yoffset = y_position_after_map_change
        current_address += 1

        x_position_after_map_change = ord(rom[current_address])
        xoffset = x_position_after_map_change
        current_address += 1

        # in pokered these were called alignments? same thing?
        self.yoffset = y_position_after_map_change
        self.xoffset = x_position_after_map_change

        # tauwasser calls this "window" and lin calls this "memoryCurrentPointer"
        # Position of the upper left block after entering the Map
        #
        # tauwasser's formula for windows:
        #   Above: C701h + Height_of_connected_map * (Width_of_connected_map + 6)
        #   Left: C706h + 2 * Width_of_connected_map
        #   Below/Right: C707h + Width_of_connected_map
        window = ord(rom[current_address]) + (ord(rom[current_address+1]) << 8)
        current_address += 2

        self.window = window

        current_map_height = self.smh.height.byte
        current_map_width  = self.smh.width.byte

        if "header_new" in map_names[connected_map_group_id][connected_map_id].keys():
            # the below code ensures that there's an equation to handle strip_pointer

            ldirection = self.direction.lower()
            connected_map_header        = map_names[connected_map_group_id][connected_map_id]["header_new"]
            connected_second_map_header = connected_map_header.second_map_header
            connected_map_height        = connected_second_map_header.height.byte
            connected_map_width         = connected_second_map_header.width.byte
            p = connected_second_map_header.blockdata.address
            h = None
            method = "default"

            if ldirection == "north":
                h = connected_map_width - self.smh.width.byte
                if ((p + ((connected_map_height * connected_map_width) - (connected_map_width * 3)))%0x4000)+0x4000 == strip_pointer:
                    # lin's equation:
                    #   p += (otherMap.height * otherMap.width) - (otherMap.width * 3)
                    p += (connected_map_height * connected_map_width) - (connected_map_width * 3)
                    method = "north1"
                elif ((p + connected_map_width + xoffset + (16 * connected_map_height) - 16)%0x4000)+0x4000 == strip_pointer:
                    p += connected_map_width + xoffset + (16 * connected_map_height) - 16
                    method = "north2"
                elif p != strip_pointer:
                    # worst case scenario: we don't know how to calculate p, so we'll just set it as a constant
                    # example: Route10North north to Route9 (strip_pointer=0x7eae, connected map's blockdata=0x7de9)
                    p = strip_pointer
                    method = "north3"
                else:
                    # this doesn't seem to ever happen
                    # or just do nothing (value is already ok)
                    method = "north4"
            elif ldirection == "west":
                h = connected_map_height - self.smh.height.byte
                if ((p + (h * connected_map_width) - (connected_map_width * 3) + (connected_map_width - 1) - 2)%0x4000)+0x4000 == strip_pointer:
                    # lin's method:
                    #   p += (h * otherMap.width) - (otherMap.width * 3) + (otherMap.width - 3)
                    p += (h * connected_map_width) - (connected_map_width * 3) + (connected_map_width - 1) - 2
                    method = "west1"
                elif ((p + connected_map_width - 3)%0x4000)+0x4000 == strip_pointer:
                    logging.debug("west h <= 0")
                    # lin's method:
                    #   p += otherMap.width - 3
                    p += connected_map_width - 3
                    method = "west2"
                elif ((p + xoffset + (current_map_height * 2))%0x4000 + 0x4000) == strip_pointer:
                    method = "west3"
                    p += xoffset + (current_map_height * 2)
                elif (p%0x4000)+0x4000 != strip_pointer:
                    # worst case scenario: dunno what to do
                    method = "west4"
                    p = strip_pointer
                else:
                    # this doesn't seem to ever happen
                    # do nothing
                    method = "west5"
            elif ldirection == "south":
                logging.debug("south.. dunno what to do?")

                if (p%0x4000)+0x4000 == strip_pointer:
                    # do nothing
                    method = "south1"
                elif ((p + (xoffset - connection_strip_length + self.smh.width.byte) / 2)%0x4000)+0x4000 == strip_pointer:
                    # comet's method
                    method = "south2"
                    p += (xoffset - connection_strip_length + self.smh.width.byte) / 2
                elif ((p + ((xoffset - connection_strip_length + self.smh.width.byte) / 2) - 1)%0x4000)+0x4000 == strip_pointer:
                    method = "south3"
                    p += ((xoffset - connection_strip_length + self.smh.width.byte) / 2) - 1
            elif ldirection == "east":
                if (p%0x4000)+0x4000 == strip_pointer:
                    # do nothing
                    method = "east1"
                elif ((p + (connected_map_height - connection_strip_length) * connected_map_width)%0x4000)+0x4000 == strip_pointer:
                    p += (connected_map_height - connection_strip_length) * connected_map_width
                    method = "east2"
                elif ((p + 100 - 4 * connected_map_width)%0x4000) + 0x4000 == strip_pointer:
                    method = "east3"
                    p += 100 - 4 * connected_map_width
                elif ((p + 2 * (100 - 4 * connected_map_width))%0x4000) + 0x4000 == strip_pointer:
                    method = "east4"
                    # the "2" is possibly ( connected_map_height / current_map_height )
                    # or current_map_width/yoffset or connected_map_width/yoffset
                    p += 2 * (100 - 4 * connected_map_width)

            # convert the address to a 2-byte pointer
            intermediate_p = p
            p = (p % 0x4000) + 0x4000

            data = {
                "strip_pointer": strip_pointer,
                "strip_length": connection_strip_length,
                "other_blockdata_address": connected_second_map_header.blockdata.address,
                "other_blockdata_pointer": (connected_second_map_header.blockdata.address%0x4000)+0x4000,

                "xoffset": xoffset,
                "yoffset": yoffset,

                "connected_map_height": connected_map_height,
                "connected_map_width": connected_map_width,
                "connected_map_group_id": connected_map_group_id,
                "connected_map_id": connected_map_id,
                "connected_map_label": map_names[connected_map_group_id][connected_map_id]["label"],

                "current_map_width": self.smh.width.byte,
                "current_map_height": self.smh.height.byte,
                "current_map_label": map_names[self.smh.map_group][self.smh.map_id]["label"],
                "current_map_group_id": self.smh.map_group,
                "current_map_id": self.smh.map_id,

                "difference": strip_pointer - ((connected_second_map_header.blockdata.address%0x4000)+0x4000),
                "direction": ldirection,
                "method": method,
            }
            strip_pointer_data.append(data)

            if p != strip_pointer:
                wowparams = {
                    "method": method,
                    "direction": ldirection,
                    "other map blockdata address": hex(connected_second_map_header.blockdata.address),
                    "h": h,
                    "initial p": hex(connected_second_map_header.blockdata.address),
                    "intermediate p": hex(intermediate_p),
                    "final p": hex(p),
                    "connection length": connection_strip_length,
                    "strip_pointer": hex(strip_pointer),
                    "other map height": connected_map_height,
                    "other map width": connected_map_width,
                }

                logging.debug(wowparams)

                whatparams = {
                    "other map group_id": hex(connected_map_group_id),
                    "other map map_id": hex(connected_map_id),
                    "other map name": +map_names[connected_map_group_id][connected_map_id]["label"],
                    "smh": hex(connected_second_map_header.address),
                    "width": connected_second_map_header.width.byte,
                    "height": connected_second_map_header.height.byte,
                }

                logging.debug(whatparams)

                curparams = {
                    "current map group_id": hex(self.map_group),
                    "current map map_id": hex(self.map_id),
                    "current map name": map_names[self.map_group][self.map_id]["label"],
                    "smh": hex(self.smh.address),
                    "width": self.smh.width.byte,
                    "height": self.smh.height.byte,
                }

                logging.debug(curparams)

                if ldirection == "east":
                    wrong_easts.append(data)
                elif ldirection == "west":
                    wrong_wests.append(data)
                elif ldirection == "south":
                    wrong_souths.append(data)
                elif ldirection == "north":
                    wrong_norths.append(data)

                # this will only happen if there's a bad formula
                raise Exception("tauwasser strip_pointer calculation was wrong? strip_pointer="+hex(strip_pointer) + " p="+hex(p))

            calculated_destination = None
            method = "strip_destination_default"
            x_movement_of_the_connection_strip_in_blocks = None
            y_movement_of_the_connection_strip_in_blocks = None

            # the below code makes sure there's an equation to calculate strip_destination
            # 11:05 <comet> Above: C803h + xoffset
            # 11:05 <comet> Below: C803h + (m.height + 3) * (m.width + 6) + xoffset
            # 11:05 <comet> Left: C800h + (m.width + 6) * (yoffset + 3)
            # 11:05 <comet> Right: C7FDh + (m.width + 6) * (yoffset + 4)
            #
            # tauwasser calls this "connection strip destination" and lin calls this "memoryOtherPointer"
            #   Points to the upper left block of the connection strip
            #   (The bank the Blockdata is in, is loaded out of the Mapheader of the connected Map.)
            #   The connection strip is always 3 Blocks high resp. wide
            #   (depending on the connection's direction)
            if ldirection == "north":
                x_movement_of_the_connection_strip_in_blocks = strip_destination - 0xC703
                logging.debug(
                    "(north) x_movement_of_the_connection_strip_in_blocks is: {0}"
                    .format(x_movement_of_the_connection_strip_in_blocks)
                )
                if x_movement_of_the_connection_strip_in_blocks < 0:
                    raise Exception("x_movement_of_the_connection_strip_in_blocks is wrong? " + str(x_movement_of_the_connection_strip_in_blocks))
            elif ldirection == "south":
                # strip_destination =
                # 0xc703 + (current_map_height + 3) * (current_map_width + 6) + x_movement_of_the_connection_strip_in_blocks
                x_movement_of_the_connection_strip_in_blocks = strip_destination - (0xc703 + (current_map_height + 3) * (current_map_width + 6))
                logging.debug(
                    "(south) x_movement_of_the_connection_strip_in_blocks is: {0}"
                    .format(x_movement_of_the_connection_strip_in_blocks)
                )
            elif ldirection == "east":
                # strip_destination =
                #   0xc700 + (current_map_width + 6) * (y_movement_of_the_connection_strip_in_blocks + 3)
                y_movement_of_the_connection_strip_in_blocks = (strip_destination - 0xc700) / (current_map_width + 6) - 3
                logging.debug(
                    "(east) y_movement_of_the_connection_strip_in_blocks is {0}"
                    .format(y_movement_of_the_connection_strip_in_blocks)
                )
            elif ldirection == "west":
                # strip_destination =
                #   0xc6fd + (current_map_width + 6) * (y_movement_of_the_connection_strip_in_blocks + 4)
                y_movement_of_the_connection_strip_in_blocks = (strip_destination - 0xc6fd) / (current_map_width + 6) - 4
                logging.debug(
                    "(west) y_movement_of_the_connection_strip_in_blocks is {0}"
                    .format(y_movement_of_the_connection_strip_in_blocks)
                )

            # let's also check the window equations
            # tauwasser calls this "window" and lin calls this "memoryCurrentPointer"
            # Position of the upper left block after entering the Map
            #
            # tauwasser's formula for windows:
            #   Above: C701h + Height_of_connected_map * (Width_of_connected_map + 6)
            #   Left: C706h + 2 * Width_of_connected_map
            #   Below/Right: C707h + Width_of_connected_map
            window_worked = False
            if ldirection == "north":
                # tauwasser's formula: 0xc701 + connected_map_height * (connected_map_width + 6)
                window_start = 0xc801
                if window == window_start + (connected_map_height * 6) + (connected_map_height * connected_map_width):
                    window_worked = True
            elif ldirection == "east":
                window_start = 0xc807
                if window == (window_start + connected_map_width):
                    window_worked = True
            elif ldirection == "south":
                window_start = 0xc807
                if window == (window_start + connected_map_width):
                    window_worked = True
            elif ldirection == "west":
                window_start = 0xc807
                if window == (window_start + xoffset):
                    window_worked = True

            data = {
                "window": window,
                "window_start": window_start,
                "window_diff": window - window_start,
                "window_worked": window_worked,
                "strip_destination": strip_destination,
                "strip_length": connection_strip_length,
                "other_blockdata_address": connected_second_map_header.blockdata.address,
                "other_blockdata_pointer": (connected_second_map_header.blockdata.address%0x4000)+0x4000,

                "xoffset": xoffset,
                "yoffset": yoffset,

                "connected_map_height": connected_map_height,
                "connected_map_width": connected_map_width,
                "connected_map_group_id": connected_map_group_id,
                "connected_map_id": connected_map_id,
                "connected_map_label": map_names[connected_map_group_id][connected_map_id]["label"],

                "current_map_width": self.smh.width.byte,
                "current_map_height": self.smh.height.byte,
                "current_map_label": map_names[self.smh.map_group][self.smh.map_id]["label"],
                "current_map_group_id": self.smh.map_group,
                "current_map_id": self.smh.map_id,

                "y_movement_of_the_connection_strip_in_blocks": y_movement_of_the_connection_strip_in_blocks,
                "x_movement_of_the_connection_strip_in_blocks": x_movement_of_the_connection_strip_in_blocks,

                "direction": ldirection,
                "method": method,
            }
            strip_destination_data.append(data)

    def to_asm(self):
        output     = ""
        ldirection = self.direction.lower()

        connected_map_group_id      = self.connected_map_group_id
        connected_map_id            = self.connected_map_id

        connected_map_header        = map_names[connected_map_group_id][connected_map_id]["header_new"]
        connected_second_map_header = connected_map_header.second_map_header
        connected_map_height        = connected_second_map_header.height.byte
        connected_map_width         = connected_second_map_header.width.byte

        connection_strip_length = self.connection_strip_length
        connected_map_width     = self.connected_map_width

        current_map_height      = self.smh.height.byte
        current_map_width       = self.smh.width.byte

        map_constant_label          = get_map_constant_label(map_group=connected_map_group_id, map_id=connected_map_id, map_internal_ids=self.map_internal_ids)
        self_constant_label         = get_map_constant_label(map_group=self.smh.map_group, map_id=self.smh.map_id, map_internal_ids=self.map_internal_ids)
        if map_constant_label != None:
            map_group_label = "GROUP_" + map_constant_label
            map_label       = "MAP_"   + map_constant_label
        else:
            map_group_label = str(connected_map_group_id)
            map_label       = str(connected_map_id)

        output += "; " + self.direction.upper() + " to " \
                  + map_names[connected_map_group_id][connected_map_id]["name"] \
                  + "\n"

        output += "db %s, %s ; connected map (group, id)\n" % (map_group_label, map_label)

        yoffset = self.yoffset
        xoffset = self.xoffset

        # According to JohtoMap, the calculation for tile data pointer is:
        #   int p = otherMap.tileDataLocation;
        #   int h = (otherMap.width - otherMap.height)
        #   if (h > 0)
        #       p += (h * otherMap.height) + (otherMap.height * 3) + (otherMap.height + 3)
        #   else
        #       p += (otherMap.height * otherMap.width) - (otherMap.width * 3);
        #   c.tileDataPointer = gb.Get2BytePointer(p);
        strip_pointer     = self.strip_pointer

        p = connected_second_map_header.blockdata.address

        output += "dw "

        if ldirection == "north":
            h = connected_map_width - self.smh.width.byte
            if ((p + ((connected_map_height * connected_map_width) - (connected_map_width * 3)))%0x4000)+0x4000 == strip_pointer:
                # lin's equation:
                #   p += (otherMap.height * otherMap.width) - (otherMap.width * 3)
                p += (connected_map_height * connected_map_width) - (connected_map_width * 3)
                method = "north1"
                output += "(" + get_label_for(connected_second_map_header.blockdata.address) + " + (" + map_constant_label + "_HEIGHT * " + map_constant_label + "_WIDTH) - (" + map_constant_label + "_WIDTH * 3))"
            elif ((p + connected_map_width + xoffset + (16 * connected_map_height) - 16)%0x4000)+0x4000 == strip_pointer:
                p += connected_map_width + xoffset + (16 * connected_map_height) - 16
                method = "north2"
                output += "(" + get_label_for(connected_second_map_header.blockdata.address) + " + " + map_constant_label + "_WIDTH + " + str(xoffset) + " + (16 * " + map_constant_label + "_HEIGHT) - 16)"
            elif p != strip_pointer:
                # worst case scenario: we don't know how to calculate p, so we'll just set it as a constant
                # example: Route10North north to Route9 (strip_pointer=0x7eae, connected map's blockdata=0x7de9)
                p = strip_pointer
                method = "north3"
                output += "$%.2x" % (p)
            else:
                # this doesn't seem to ever happen
                # or just do nothing (value is already ok)
                method = "north4"
                output += "(" + get_label_for(connected_second_map_header.blockdata.address) + ")"
        elif ldirection == "west":
            h = connected_map_height - self.smh.height.byte
            h_out = "(" + map_constant_label +"_HEIGHT - " + self_constant_label +"_HEIGHT)"
            if ((p + (h * connected_map_width) - (connected_map_width * 3) + (connected_map_width - 1) - 2)%0x4000)+0x4000 == strip_pointer:
                # lin's method:
                #   p += (h * otherMap.width) - (otherMap.width * 3) + (otherMap.width - 3)
                p += (h * connected_map_width) - (connected_map_width * 3) + (connected_map_width - 1) - 2
                method = "west1"
                this_part = "((" + h_out + " * " + map_constant_label + "_WIDTH) - (" + map_constant_label + "_WIDTH * 3) + (" + map_constant_label + "_WIDTH - 1) - 2)"
                output += "(" + get_label_for(connected_second_map_header.blockdata.address) + " + " + this_part + ")"
            elif ((p + connected_map_width - 3)%0x4000)+0x4000 == strip_pointer:
                logging.debug("west h <= 0")
                # lin's method:
                #   p += otherMap.width - 3
                p += connected_map_width - 3
                method = "west2"
                output += "(" + get_label_for(connected_second_map_header.blockdata.address) + " + " + map_constant_label + "_WIDTH - 3)"
            elif ((p + xoffset + (current_map_height * 2))%0x4000 + 0x4000) == strip_pointer:
                method = "west3"
                p += xoffset + (current_map_height * 2)
                output += "(" + get_label_for(connected_second_map_header.blockdata.address) + " + " + str(xoffset) + " + (" + map_constant_label + "_HEIGHT * 2))"
            elif (p%0x4000)+0x4000 != strip_pointer:
                # worst case scenario: dunno what to do
                method = "west4"
                p = strip_pointer
                output += "$%.2x" % ((p%0x4000)+0x4000)
            else:
                # this doesn't seem to ever happen
                # do nothing
                method = "west5"
                output += "(" + get_label_for(connected_second_map_header.blockdata.address) + ")"
        elif ldirection == "south":
            if (p%0x4000)+0x4000 == strip_pointer:
                # do nothing
                method = "south1"
                output += "(" + get_label_for(connected_second_map_header.blockdata.address) + ")"
            elif ((p + (xoffset - connection_strip_length + self.smh.width.byte) / 2)%0x4000)+0x4000 == strip_pointer:
                # comet's method
                method = "south2"
                p += (xoffset - connection_strip_length + self.smh.width.byte) / 2
                this_part = "((" + str(xoffset) + " - " + str(connection_strip_length) + " + " + self_constant_label + "_WIDTH) / 2)"
                output += "(" + get_label_for(connected_second_map_header.blockdata.address) + " + " + this_part + ")"
            elif ((p + ((xoffset - connection_strip_length + self.smh.width.byte) / 2) - 1)%0x4000)+0x4000 == strip_pointer:
                method = "south3"
                p += ((xoffset - connection_strip_length + self.smh.width.byte) / 2) - 1
                this_part = "(((" + str(xoffset) + " - " + str(connection_strip_length) + " + " + self_constant_label + "_WIDTH) / 2) - 1)"
                output += "(" + get_label_for(connected_second_map_header.blockdata.address) + " + " + this_part + ")"
        elif ldirection == "east":
            if (p%0x4000)+0x4000 == strip_pointer:
                # do nothing
                method = "east1"
                output += "(" + get_label_for(connected_second_map_header.blockdata.address) + ")"
            elif ((p + (connected_map_height - connection_strip_length) * connected_map_width)%0x4000)+0x4000 == strip_pointer:
                p += (connected_map_height - connection_strip_length) * connected_map_width
                method = "east2"
                this_part = "((" + map_constant_label + "_HEIGHT - " + str(connection_strip_length) + ") * " + map_constant_label + "_WIDTH)"
                output += "(" + get_label_for(connected_second_map_header.blockdata.address) + " + " + this_part +  ")"
            elif ((p + 100 - 4 * connected_map_width)%0x4000) + 0x4000 == strip_pointer:
                method = "east3"
                p += 100 - 4 * connected_map_width
                output += "(" + get_label_for(connected_second_map_header.blockdata.address) + " + 100 - (" + map_constant_label + "_WIDTH * 4))"
            elif ((p + 2 * (100 - 4 * connected_map_width))%0x4000) + 0x4000 == strip_pointer:
                method = "east4"
                # the "2" is possibly ( connected_map_height / current_map_height )
                # or current_map_width/yoffset or connected_map_width/yoffset
                p += 2 * (100 - 4 * connected_map_width)
                output += "(" + get_label_for(connected_second_map_header.blockdata.address) + " + ((100 - (" + map_constant_label + "_WIDTH * 4)) * 2))"

        output += " ; strip pointer\n"

        # tauwasser calls this "connection strip destination" and lin calls this "memoryOtherPointer"
        #   Points to the upper left block of the connection strip
        #   (The bank the Blockdata is in, is loaded out of the Mapheader of the connected Map.)
        #   The connection strip is always 3 Blocks high resp. wide
        #   (depending on the connection's direction)
        strip_destination = self.strip_destination

        output += "dw "

        # i am not convinced about these calculations
        if ldirection == "north":
            x_movement_of_the_connection_strip_in_blocks = strip_destination - 0xC703
            xmov = x_movement_of_the_connection_strip_in_blocks
            output += "($C703 + " + str(xmov) + ")"
        elif ldirection == "south":
            # strip_destination =
            # 0xc703 + (current_map_height + 3) * (current_map_width + 6) + x_movement_of_the_connection_strip_in_blocks
            x_movement_of_the_connection_strip_in_blocks = strip_destination - (0xc703 + (current_map_height + 3) * (current_map_width + 6))
            xmov = x_movement_of_the_connection_strip_in_blocks
            #output += "($C703 + (((" + self_constant_label + "_HEIGHT + 3) * (" + self_constant_label + "_WIDTH + 6)) + " + str(xmov) + "))"

            # xmov = strip_destination - (0xc703 + (current_map_height + 3) * (current_map_width + 6))
            #difference = 0xC715 + xmov + 6*current_map_height + 3*current_map_width + current_map_width*current_map_height
            #difference = 50965 + ymov + 6*current_map_height + 3*current_map_width + current_map_width*current_map_height

            output += "($C703 + " + str(xmov) + " + ((" + self_constant_label + "_HEIGHT + 3) * (" + self_constant_label + "_WIDTH + 6)))"
        elif ldirection == "east":
            # strip_destination =
            #   0xc700 + (current_map_width + 6) * (y_movement_of_the_connection_strip_in_blocks + 3)
            y_movement_of_the_connection_strip_in_blocks = (strip_destination - 0xc700) / (current_map_width + 6) - 3
            ymov = y_movement_of_the_connection_strip_in_blocks
            #output += "($C700 + ((" + self_constant_label + "_WIDTH + 6) * (" + str(ymov) + " + 3)) + "+str(ymov)+")"
            output += "$%.2x" % (strip_destination)
        elif ldirection == "west":
            # strip_destination =
            # 0xc6fd + (current_map_width + 6) * (y_movement_of_the_connection_strip_in_blocks + 4)
            y_movement_of_the_connection_strip_in_blocks = (strip_destination - 0xc700) / (current_map_width + 6) - 3
            ymov = y_movement_of_the_connection_strip_in_blocks
            #output += "($C700 + ((" + self_constant_label + "_WIDTH + 6) * (" + str(ymov) + " + 4)) - 4)"
            output += "$%.2x" % (strip_destination)
        output += " ; strip destination\n"

        output += "db " + str(connection_strip_length,) + ", " + map_constant_label + "_WIDTH ; (connection strip length, connected map width)\n"

        #if ldirection in ["east", "west"]:
        #    Y_movement_of_connection_strip_in_blocks =
        #elif direction in ["north", "south"]:
        #    X_movement_of_connection_strip_in_blocks =

        # Above: (Height_of_connected_map * 2) - 1
        # Below: 0
        # Left/Right: (Y_movement_of_connection_strip_in_blocks * -2)
        yoffset = self.yoffset # y_position_after_map_change

        if ldirection == "south" and yoffset != 0:
            raise Exception("tauwasser was wrong about yoffset=0 for south? it's: " + str(yoffset))
        elif ldirection == "north" and yoffset != ((connected_map_height * 2) - 1):
            raise Exception("tauwasser was wrong about yoffset for north? it's: " + str(yoffset))
        #elif not ((yoffset % -2) == 0):
        #    raise Exception("tauwasser was wrong about yoffset for west/east? it's not divisible by -2: " + str(yoffset))

        # Left: (Width_of_connected_map * 2) - 1
        # Right: 0
        # Above/Below: (X_movement_of_connection_strip_in_blocks * -2)
        xoffset = self.xoffset # x_position_after_map_change

        if ldirection == "east" and xoffset != 0:
            raise Exception("tauwasser was wrong about xoffset=0 for east? it's: " + str(xoffset))
        elif ldirection == "west" and xoffset != ((connected_map_width * 2) - 1):
            raise Exception("tauwasser was wrong about xoffset for west? it's: " + str(xoffset))
        #elif not ((xoffset % -2) == 0):
        #    raise Exception("tauwasser was wrong about xoffset for north/south? it's not divisible by -2: " + str(xoffset))

        output += "db "

        if ldirection == "south":
            output += "0"
        elif ldirection == "north":
            output += "((" + map_constant_label + "_HEIGHT * 2) - 1)"
        else:
            output += str(yoffset)

        output += ", "

        if ldirection == "east":
            output += "0"
        elif ldirection == "west":
            output += "((" + map_constant_label + "_WIDTH * 2) - 1)"
        else:
            output += str(xoffset)

        output += " ; yoffset, xoffset\n"

        window = self.window

        output += "dw "

        # let's also check the window equations
        # tauwasser calls this "window" and lin calls this "memoryCurrentPointer"
        # Position of the upper left block after entering the Map
        #
        # tauwasser's formula for windows:
        #   Above: C701h + Height_of_connected_map * (Width_of_connected_map + 6)
        #   Left: C706h + 2 * Width_of_connected_map
        #   Below/Right: C707h + Width_of_connected_map
        window_worked = False
        if ldirection == "north":
            # tauwasser's formula: 0xc701 + connected_map_height * (connected_map_width + 6)
            window_start = 0xc801
            if window == window_start + (connected_map_height * 6) + (connected_map_height * connected_map_width):
                window_worked = True
                output += "($C801 + ((" + map_constant_label + "_HEIGHT * 6) + (" + map_constant_label + "_HEIGHT * " + map_constant_label + "_WIDTH)))"
        elif ldirection == "east":
            window_start = 0xc807
            if window == (window_start + connected_map_width):
                window_worked = True
                output += "($C807 + " + map_constant_label + "_WIDTH)"
        elif ldirection == "south":
            window_start = 0xc807
            if window == (window_start + connected_map_width):
                window_worked = True
                output += "($C807 + " + map_constant_label + "_WIDTH)"
        elif ldirection == "west":
            window_start = 0xc807
            if window == (window_start + xoffset):
                window_worked = True
                output += "($C807 + " + str(xoffset) + ")"

        output += " ; window"

        return output

all_second_map_headers = []
def parse_second_map_header_at(address, map_group=None, map_id=None, debug=True):
    """each map has a second map header"""
    smh = SecondMapHeader(address, map_group=map_group, map_id=map_id, debug=debug)
    all_second_map_headers.append(smh)
    return smh

class MapBlockData:
    base_label = "MapBlockData_"
    maps_path = os.path.realpath(os.path.join(conf.path, "maps"))

    def __init__(self, address, map_group=None, map_id=None, debug=True, bank=None, label=None, width=None, height=None):
        self.address = address
        self.map_group = map_group
        self.map_id = map_id
        self.map_name = map_names[map_group][map_id]["label"]
        self.map_path = os.path.join(self.maps_path, self.map_name + ".blk")
        self.debug = debug
        self.bank = bank
        if width and height:
            self.width = width
            self.height = height
        else:
            raise Exception("MapBlockData needs to know the width/height of its map")
        label = self.make_label()
        self.label = Label(name=label, address=address, object=self)
        self.last_address = self.address + (self.width.byte * self.height.byte)
        script_parse_table[address : self.last_address] = self
        self.parse()

    def make_label(self):
        return map_names[self.map_group][self.map_id]["label"] + "_BlockData"

    def save_to_file(self):
        # check if the file exists already
        map_path = self.map_path
        if not os.path.exists(self.maps_path):
            os.mkdir(self.maps_path)
        if not os.path.exists(map_path):
            # dump to file
            #bytes = rom.interval(self.address, self.width.byte*self.height.byte, strings=True)
            bytes = rom[self.address : self.address + self.width.byte*self.height.byte]
            file_handler = open(map_path, "w")
            file_handler.write(bytes)
            file_handler.close()

    def parse(self):
        self.save_to_file()

    def to_asm(self):
        return "INCBIN \"maps/"+self.map_name+".blk\""


class MapEventHeader:
    base_label = "MapEventHeader_"

    def __init__(self, address, map_group=None, map_id=None, debug=True, bank=None, label=None):
        logging.debug(
            "making a MapEventHeader at {address} map_group={map_group} map_id={map_id}"
            .format(
                address=hex(address),
                map_group=map_group,
                map_id=map_id,
            )
        )
        self.address = address
        self.map_group = map_group
        self.map_id = map_id
        self.debug = debug
        self.bank = bank
        self.dependencies = None
        label = self.make_label()
        self.label = Label(name=label, address=address, object=self)
        self.parse()
        script_parse_table[address : self.last_address] = self

    def make_label(self):
        return map_names[self.map_group][self.map_id]["label"] + "_MapEventHeader"

    def parse(self):
        map_group, map_id, debug = self.map_group, self.map_id, self.debug
        address = self.address
        bank = pointers.calculate_bank(self.address) # or use self.bank
        logging.debug("event header address is {0}".format(hex(address)))

        filler1 = ord(rom[address])
        filler2 = ord(rom[address+1])
        self.fillers = [filler1, filler2]

        # warps
        warp_count = ord(rom[address+2])
        warp_byte_count = warp_byte_size * warp_count
        after_warps = address + 3 + warp_byte_count
        warps = parse_warps(address+3, warp_count, bank=bank, map_group=map_group, map_id=map_id, debug=debug)
        self.warp_count = warp_count
        self.warps = warps

        # triggers (based on xy location)
        xy_trigger_count = ord(rom[after_warps])
        trigger_byte_count = trigger_byte_size * xy_trigger_count
        xy_triggers = parse_xy_triggers(after_warps+1, xy_trigger_count, bank=bank, map_group=map_group, map_id=map_id, debug=debug)
        after_triggers = after_warps + 1 + trigger_byte_count
        self.xy_trigger_count = xy_trigger_count
        self.xy_triggers = xy_triggers

        # signposts
        signpost_count = ord(rom[after_triggers])
        signpost_byte_count = signpost_byte_size * signpost_count
        # signposts = rom.interval(after_triggers+1, signpost_byte_count)
        signposts = parse_signposts(after_triggers+1, signpost_count, bank=bank, map_group=map_group, map_id=map_id, debug=debug)
        after_signposts = after_triggers + 1 + signpost_byte_count
        self.signpost_count = signpost_count
        self.signposts = signposts

        # people events
        people_event_count = ord(rom[after_signposts])
        people_event_byte_count = people_event_byte_size * people_event_count
        # people_events_bytes = rom.interval(after_signposts+1, people_event_byte_count)
        # people_events = parse_people_event_bytes(people_events_bytes, address=after_signposts+1, map_group=map_group, map_id=map_id)
        people_events = parse_people_events(after_signposts+1, people_event_count, bank=pointers.calculate_bank(after_signposts+2), map_group=map_group, map_id=map_id, debug=debug)
        self.people_event_count = people_event_count
        self.people_events = people_events

        if people_event_count > 0:
            self.last_address = people_events[-1].last_address
        else:
            self.last_address = after_signposts+1
        return True

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        if self.dependencies != None and not recompute:
            global_dependencies.update(self.dependencies)
            return self.dependencies
        bases = []
        bases += self.people_events
        bases += self.signposts
        bases += self.xy_triggers
        bases += self.warps

        dependencies = []
        for p in bases:
            dependencies.extend(p.get_dependencies(recompute=recompute, global_dependencies=global_dependencies))
        self.dependencies = dependencies
        return dependencies

    def to_asm(self):
        xspacing = "" # was =spacing
        output = "; filler\n"
        output += "db %d, %d\n\n" % (self.fillers[0], self.fillers[1])

        output += xspacing + "; warps\n"
        output += xspacing + "db %d"%(self.warp_count)
        if len(self.warps) > 0:
            output += "\n"
        output += "\n".join([xspacing+warp.to_asm() for warp in self.warps])

        output += "\n\n"
        output += xspacing + "; xy triggers\n"
        output += xspacing + "db %d"%(self.xy_trigger_count)
        if len(self.xy_triggers) > 0:
            output += "\n"
        output += "\n".join([xspacing+xy_trigger.to_asm() for xy_trigger in self.xy_triggers])

        output += "\n\n"
        output += xspacing + "; signposts\n"
        output += xspacing + "db %d"%(self.signpost_count)
        if len(self.signposts) > 0:
            output += "\n"
        output += "\n".join([xspacing+signpost.to_asm() for signpost in self.signposts])

        output += "\n\n"
        output += xspacing + "; people-events\n"
        output += xspacing + "db %d"%(self.people_event_count)
        if len(self.people_events) > 0:
            output += "\n"

        for people_event in self.people_events:
            output += xspacing
            output += people_event.to_asm()
            output += "\n"

        if output[-1] == "\n":
            output = output[:-1]
        return output

all_map_event_headers = []
def parse_map_event_header_at(address, map_group=None, map_id=None, debug=True, bank=None):
    """parse crystal map event header byte structure thing"""
    ev = MapEventHeader(address, map_group=map_group, map_id=map_id, debug=debug, bank=bank)
    all_map_event_headers.append(ev)
    return ev

class MapScriptHeader:
    """parses a script header

    This structure allows the game to have e.g. one-time only events on a map
    or first enter events or permanent changes to the map or permanent script
    calls.

    This header a combination of a trigger script section and a callback script
    section. I don't know if these 'trigger scripts' are the same as the others
    referenced in the map event header, so this might need to be renamed very
    soon. The scripts in MapEventHeader are called XYTrigger.

    trigger scripts:
    [[Number1 of pointers] Number1 * [2byte pointer to script][00][00]]

    callback scripts:
    [[Number2 of pointers] Number2 * [hook number][2byte pointer to script]]

    hook byte choices:
        01 - map data has already been loaded to ram, tileset and sprites still missing
            map change (3rd step)
            loading (2nd step)
            map connection (3rd step)
            after battle (1st step)
        02 - map data, tileset and sprites are all loaded
            map change (5th step)
        03 - neither map data not tilesets nor sprites are loaded
            map change (2nd step)
            loading (1st step)
            map connection (2nd step)
        04 - map data and tileset loaded, sprites still missing
            map change (4th step)
            loading (3rd step)
            sprite reload (1st step)
            map connection (4th step)
            after battle (2nd step)
        05 - neither map data not tilesets nor sprites are loaded
            map change (1st step)
            map connection (1st step)

    When certain events occur, the call backs will be called in this order (same info as above):
        map change:
            05, 03, 01, 04, 02
        loading:
            03, 01, 04
        sprite reload:
            04
        map connection:
            05, 03, 01, 04 note that #2 is not called (unlike "map change")
        after battle:
            01, 04
    """
    base_label = "MapScriptHeader_"

    def __init__(self, address, map_group=None, map_id=None, debug=True, bank=None, label=None):
        logging.debug(
            "creating a MapScriptHeader at {address} map_group={map_group} map_id={map_id}"
            .format(
                address=hex(address),
                map_group=map_group,
                map_id=map_id,
            )
        )
        self.address = address
        self.map_group = map_group
        self.map_id = map_id
        self.debug = debug
        self.bank = bank
        self.dependencies = None
        label = self.make_label()
        self.label = Label(name=label, address=address, object=self)
        self.parse()
        script_parse_table[address : self.last_address] = self

    def make_label(self):
        return map_names[self.map_group][self.map_id]["label"] + "_MapScriptHeader"

    def parse(self):
        address = self.address
        map_group = self.map_group
        map_id = self.map_id
        debug = self.debug
        #[[Number1 of pointers] Number1 * [2byte pointer to script][00][00]]
        self.trigger_count = ord(rom[address])
        self.triggers = []
        ptr_line_size = 4
        groups = helpers.grouper(rom.interval(address+1, self.trigger_count * ptr_line_size, strings=False), count=ptr_line_size)
        current_address = address+1
        for (index, trigger_bytes) in enumerate(groups):
            logging.debug(
                "parsing a map trigger script at {address} map_group={map_group} map_id={map_id}"
                .format(
                    address=hex(current_address),
                    map_group=map_group,
                    map_id=map_id,
                )
            )
            script = ScriptPointerLabelParam(address=current_address, map_group=map_group, map_id=map_id, debug=debug)
            extra_bytes = MultiByteParam(address=current_address+2, map_group=map_group, map_id=map_id, debug=debug)
            self.triggers.append([script, extra_bytes])
            current_address += ptr_line_size
        current_address = address + (self.trigger_count * ptr_line_size) + 1
        #[[Number2 of pointers] Number2 * [hook number][2byte pointer to script]]
        callback_ptr_line_size = 3
        self.callback_count = DecimalParam(address=current_address)
        self.callback_count = self.callback_count.byte
        current_address += 1
        self.callbacks = []
        for index in range(self.callback_count):
            logging.debug(
                "parsing a callback script at {address} map_group={map_group} map_id={map_id}"
                .format(
                    address=hex(current_address),
                    map_group=map_group,
                    map_id=map_id,
                )
            )
            hook_byte = HexByte(address=current_address)
            callback = ScriptPointerLabelParam(address=current_address+1, map_group=map_group, map_id=map_id, debug=debug)
            self.callbacks.append({"hook": hook_byte, "callback": callback})
            current_address += 3 # i think?
        self.last_address = current_address
        logging.debug(
            "done parsing a MapScriptHeader map_group={map_group} map_id={map_id}"
            .format(map_group=map_group, map_id=map_id)
        )
        return True

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        if self.dependencies != None and not recompute:
            global_dependencies.update(self.dependencies)
            return self.dependencies
        dependencies = []
        for p in list(self.triggers):
            # dependencies.append(p[0])
            dependencies.extend(p[0].get_dependencies(recompute=recompute, global_dependencies=global_dependencies))
        for callback in self.callbacks:
            dependencies.append(callback["callback"])
            global_dependencies.add(callback["callback"])
            dependencies.extend(callback["callback"].get_dependencies(recompute=recompute, global_dependencies=global_dependencies))
        self.dependencies = dependencies
        return dependencies

    def to_asm(self):
        output = ""
        output += "; trigger count\n"
        output += "db %d\n"%self.trigger_count
        if len(self.triggers) > 0:
            output += "\n; triggers\n"
            output += "\n".join([str("dw "+p[0].to_asm()+", "+p[1].to_asm()) for p in self.triggers])
            output += "\n"
        output += "\n; callback count\n"
        output += "db %d"%self.callback_count
        if len(self.callbacks) > 0:
            output += "\n\n; callbacks\n\n"
            output += "\n\n".join(["dbw "+str(p["hook"].byte)+", "+p["callback"].to_asm() for p in self.callbacks])
        return output

all_map_script_headers = []
def parse_map_script_header_at(address, map_group=None, map_id=None, debug=True):
    evv = MapScriptHeader(address, map_group=map_group, map_id=map_id, debug=debug)
    all_map_script_headers.append(evv)
    return evv

def parse_map_header_by_id(*args, **kwargs):
    """convenience function to parse a specific map"""
    map_group, map_id = None, None
    all_map_headers = kwargs["all_map_headers"]
    if "map_group" in kwargs.keys():
        map_group = kwargs["map_group"]
    if "map_id" in kwargs.keys():
        map_id = kwargs["map_id"]
    if (map_group == None and map_id != None) or \
       (map_group != None and map_id == None):
        raise Exception("map_group and map_id must both be provided")
    elif map_group == None and map_id == None and len(args) == 0:
        raise Exception("must be given an argument")
    elif len(args) == 1 and type(args[0]) == str:
        map_group = int(args[0].split(".")[0])
        map_id = int(args[0].split(".")[1])
    elif map_group == None and map_id == None:
        raise Exception("dunno what to do with input")
    offset = map_names[map_group]["offset"]
    map_header_offset = offset + ((map_id - 1) * map_header_byte_size)
    return parse_map_header_at(map_header_offset, all_map_headers=all_map_headers, map_group=map_group, map_id=map_id)

def parse_all_map_headers(map_names, all_map_headers=None, debug=True):
    """
    Calls parse_map_header_at for each map in each map group. Updates the
    map_names structure.
    """
    if not map_names[1].has_key("offset"):
        raise Exception("dunno what to do - map_names should have groups with pre-calculated offsets by now")
    for (group_id, group_data) in map_names.items():
        offset = group_data["offset"]
        # we only care about the maps
        #del group_data["offset"]
        for (map_id, map_data) in group_data.items():
            if map_id == "offset": continue # skip the "offset" address for this map group
            if debug:
                logging.debug(
                    "map_group={group_id} map_id={map_id}"
                    .format(group_id=group_id, map_id=map_id)
                )
            map_header_offset = offset + ((map_id - 1) * map_header_byte_size)
            map_names[group_id][map_id]["header_offset"] = map_header_offset

            new_parsed_map = parse_map_header_at(map_header_offset, map_group=group_id, map_id=map_id, all_map_headers=all_map_headers, debug=debug)
            map_names[group_id][map_id]["header_new"] = new_parsed_map

class PokedexEntryPointerTable:
    """
    A list of pointers.
    """

    def __init__(self):
        self.address = 0x44378
        self.target_bank = pointers.calculate_bank(0x181695)
        self.label = Label(name="PokedexDataPointerTable", address=self.address, object=self)
        self.size = None
        self.last_address = None
        self.dependencies = None
        self.entries = []
        self.parse()

        script_parse_table[self.address : self.last_address] = self

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        global_dependencies.update(self.entries)
        dependencies = []
        [dependencies.extend(entry.get_dependencies(recompute=recompute, global_dependencies=global_dependencies)) for entry in self.entries]
        return dependencies

    def parse(self):
        size = 0
        lastpointer = 0
        for i in range(251):
            # Those are consecutive in GS!
            if i == 0x40:
                self.target_bank = 0x6e
            elif i == 0x80:
                self.target_bank = 0x73
            elif i == 0xc0:
                self.target_bank = 0x74
            loc = self.address+(i*2)
            pointer = calculate_pointer_from_bytes_at(loc, bank=self.target_bank)
            #print(hex(pointer))
            #if pointer < lastpointer:
            #    self.target_bank += 1
            #    pointer += 0x4000
            self.entries.append(PokedexEntry(pointer, i+1))

            size += 2
        self.size = size
        self.last_address = self.address + self.size

    def to_asm(self):
        output = "".join([str("dw "+get_label_for(entry.address)+"\n") for entry in self.entries])
        return output

class PokedexEntry:
    def __init__(self, address, pokemon_id):
        self.address = address
        self.dependencies = None
        #label = self.make_label()
        if pokemon_id in pokemon_constants.pokemon_constants:
            pokename = string.capwords(pokemon_constants.pokemon_constants[pokemon_id].replace("__", " ").replace("_", " ")).replace(" ", "")
        else:
            pokename = "Pokemon{0}".format(pokemon_id)
        self.label = Label(name=pokename+"PokedexEntry", address=self.address, object=self)
        self.parse()
        script_parse_table[address : self.last_address] = self

    def get_dependencies(self, recompute=False, global_dependencies=set()):
        return []

    def parse(self):
        # eww.
        address = self.address
        jump = how_many_until(chr(0x50), address, rom)
        self.species = parse_text_at(address, jump+1)
        address = address + jump + 1

        self.weight = ord(rom[address  ]) + (ord(rom[address+1]) << 8)
        self.height = ord(rom[address+2]) + (ord(rom[address+3]) << 8)
        address += 4

        jump = how_many_until(chr(0x50), address, rom)
        self.page1 = PokedexText(address)
        address = address + jump + 1
        jump = how_many_until(chr(0x50), address, rom)
        self.page2 = PokedexText(address)

        self.last_address = address + jump + 1
        #print(self.to_asm())
        return True

    def to_asm(self):
        output = """\
    db "{0}" ; species name
    dw {1}, {2} ; height, weight

    {3}
    {4}""".format(self.species, self.weight, self.height, self.page1.to_asm(), self.page2.to_asm())
        return output

# map names with no labels will be generated
# generate labels for each map name
for map_group_id in map_names.keys():
    map_group = map_names[map_group_id]
    for map_id in map_group.keys():
        # skip if we maybe already have the 'offset' label set in this map group
        if map_id == "offset": continue
        # skip if we provided a pre-set value for the map's label
        if map_group[map_id].has_key("label"): continue
        # convience alias
        map_data = map_group[map_id]
        # clean up the map name to be an asm label
        cleaned_name = map_name_cleaner(map_data["name"])
        # set the value in the original dictionary
        map_names[map_group_id][map_id]["label"] = cleaned_name
# generate map constants (like 1=PALLET_TOWN)
generate_map_constant_labels()

#### asm utilities ####
# these are pulled in from pokered/extras/analyze_incbins.py

# store each line of source code here
asm = None

# store each incbin line separately
incbin_lines = []

# storage for processed incbin lines
processed_incbins = {}

def to_asm(some_object, use_asm_rules=False):
    """shows an object's asm with a label and an ending comment
    showing the next byte address"""
    if isinstance(some_object, int):
        some_object = script_parse_table[some_object]
    # add one to the last_address to show where the next byte is in the file
    last_address = some_object.last_address
    # create a line like "label: ; 0x10101"
    asm = some_object.label.name + ": ; " + hex(some_object.address) + "\n"
    # now add the inner/actual asm
    #asm += spacing + some_object.to_asm().replace("\n", "\n"+spacing).replace("\n"+spacing+"\n"+spacing, "\n\n"+spacing)
    asmr = some_object.to_asm()
    asmr = asmr.replace("\n", "\n"+spacing)
    asmr = asmr.replace("\n"+spacing+"\n", "\n\n"+spacing)
    asmr = asmr.replace("\n\n"+spacing+spacing, "\n\n"+spacing)
    asm += spacing + asmr
    if use_asm_rules:
        asm = asm.replace("\n" + spacing + "; ", "\n; ")
        asm = asm.replace("\n" + spacing + ".asm_", "\n.asm_")
    # show the address of the next byte below this
    asm += "\n; " + hex(last_address)
    return asm

def get_dependencies_for(some_object, recompute=False, global_dependencies=set()):
    """
    calculates which labels need to be satisfied for an object
    to be inserted into the asm and compile successfully.

    You could also choose to not insert labels into the asm, but
    then you're losing out on the main value of having asm in the
    first place.
    """
    try:
        if isinstance(some_object, int):
            some_object = script_parse_table[some_object]
        if some_object.dependencies != None and not recompute:
            global_dependencies.update(some_object.dependencies)
        else:
            some_object.get_dependencies(recompute=recompute, global_dependencies=global_dependencies)
        return global_dependencies
    except RuntimeError, e:
        # 1552, 1291, 2075, 1552, 1291...

        errorargs = {
            "some_object": some_object,
            "class type": some_object.__class__,
            "label name": some_object.label.name,
            "address": some_object.address,
            "asm": to_asm(some_object),
        }

        logging.debug(str(errorargs))

        raise e

def isolate_incbins(asm=None):
    "find each incbin line"
    global incbin_lines
    if asm == None:
        asm = globals()["asm"]
    incbin_lines = []
    for line in asm:
        if line == "": continue
        if line.count(" ") == len(line): continue

        # clean up whitespace at beginning of line
        while line[0] == " ":
            line = line[1:]

        if line[0:6] == "INCBIN" and "baserom.gbc" in line:
            incbin_lines.append(line)
    return incbin_lines

def process_incbins():
    "parse incbin lines into memory"
    global asm, incbin_lines, processed_incbins
    # load asm if it isn't ready yet
    if asm == [] or asm == None:
        load_asm()
    # get a list of incbins if that hasn't happened yet
    if incbin_lines == [] or incbin_lines == None:
        isolate_incbins(asm=asm)
    # reset the global that this function creates
    processed_incbins = {}
    # for each incbin..
    for incbin in incbin_lines:
        # reset this entry
        processed_incbin = {}
        # get the line number from the global asm line list
        line_number = asm.index(incbin)
        # forget about all the leading characters
        partial_start = incbin[21:]
        start = partial_start.split(",")[0].replace("$", "0x")
        start = eval(start)
        start_hex = hex(start).replace("0x", "$")

        partial_interval = incbin[21:].split(",")[1]
        partial_interval = partial_interval.replace(";", "#")
        partial_interval = partial_interval.replace("$", "0x").replace("0xx", "0x")
        interval = eval(partial_interval)
        interval_hex = hex(interval).replace("0x", "$").replace("x", "")

        end = start + interval
        end_hex = hex(end).replace("0x", "$")

        processed_incbin = {"line_number": line_number,
                            "line": incbin,
                            "start": start,
                            "interval": interval,
                            "end": end, }
        # don't add this incbin if the interval is 0
        if interval != 0:
            processed_incbins[line_number] = processed_incbin
    return processed_incbins

def reset_incbins():
    "reset asm before inserting another diff"
    global asm, incbin_lines, processed_incbins
    asm = None
    incbin_lines = []
    processed_incbins = {}
    load_asm()
    isolate_incbins(asm=asm)
    process_incbins()

def find_incbin_to_replace_for(address, debug=False, rom_file=None):
    """returns a line number for which incbin to edit
    if you were to insert bytes into main.asm"""
    if rom_file == None:
        rom_file = os.path.join(conf.path, "baserom.gbc")
    if type(address) == str: address = int(address, 16)
    if not (0 <= address <= os.lstat(rom_file).st_size):
        raise IndexError("address is out of bounds")
    for incbin_key in processed_incbins.keys():
        incbin = processed_incbins[incbin_key]
        start = incbin["start"]
        end = incbin["end"]
        if debug:
            argstuff = {
                "start": start,
                "end": end,
                "address": str(type(address)),
            }

            logging.debug(str(argstuff))
            logging.debug(
                "checking... {start} <= {address} <= {end}"
                .format(
                    start=hex(start),
                    address=hex(address),
                    end=hex(end),
                )
            )
        if start <= address <= end:
            return incbin_key
    return None

def split_incbin_line_into_three(line, start_address, byte_count, rom_file=None):
    """
    splits an incbin line into three pieces.
    you can replace the middle one with the new content of length bytecount

    start_address: where you want to start inserting bytes
    byte_count: how many bytes you will be inserting
    """
    if rom_file == None:
        rom_file = os.path.join(conf.path, "baserom.gbc")
    if type(start_address) == str: start_address = int(start_address, 16)
    if not (0 <= start_address <= os.lstat(rom_file).st_size):
        raise IndexError("start_address is out of bounds")
    if len(processed_incbins) == 0:
        raise Exception("processed_incbins must be populated")

    original_incbin = processed_incbins[line]
    start = original_incbin["start"]
    end = original_incbin["end"]

    # start, end1, end2 (to be printed as start, end1 - end2)
    if start_address - start > 0:
        first = (start, start_address, start)
    else:
        first = (None) # skip this one because we're not including anything

    # this is the one you will replace with whatever content
    second = (start_address, byte_count)

    third = (start_address + byte_count, end - (start_address + byte_count))

    output = ""

    if first:
        output += "INCBIN \"baserom.gbc\",$" + hex(first[0])[2:] + ",$" + hex(first[1])[2:] + " - $" + hex(first[2])[2:] + "\n"
    output += "INCBIN \"baserom.gbc\",$" + hex(second[0])[2:] + "," + str(byte_count) + "\n"
    output += "INCBIN \"baserom.gbc\",$" + hex(third[0])[2:] + ",$" + hex(third[1])[2:] # no newline
    return output

def generate_diff_insert(line_number, newline, debug=False):
    """generates a diff between the old main.asm and the new main.asm
    note: requires python2.7 i think? b/c of subprocess.check_output"""
    global asm
    original = "\n".join(line for line in asm)
    newfile = deepcopy(asm)
    newfile[line_number] = newline # possibly inserting multiple lines
    newfile = "\n".join(line for line in newfile)

    # make sure there's a newline at the end of the file
    if newfile[-1] != "\n":
        newfile += "\n"

    original_filename = "ejroqjfoad.temp"
    newfile_filename = "fjiqefo.temp"

    original_fh = open(original_filename, "w")
    original_fh.write(original)
    original_fh.close()

    newfile_fh = open(newfile_filename, "w")
    newfile_fh.write(newfile)
    newfile_fh.close()

    try:
        from subprocess import CalledProcessError
    except ImportError:
        CalledProcessError = None

    try:
        diffcontent = subprocess.check_output("diff -u " + os.path.join(conf.path, "main.asm") + " " + newfile_filename, shell=True)
    except (AttributeError, CalledProcessError):
        p = subprocess.Popen(["diff", "-u", os.path.join(conf.path, "main.asm"), newfile_filename], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = p.communicate()
        diffcontent = out

    os.system("rm " + original_filename)
    os.system("rm " + newfile_filename)

    if debug:
        logging.debug("diffcontent is {0}".format(diffcontent))
    return diffcontent

def apply_diff(diff, try_fixing=True, do_compile=True):
    logging.info("Applying diff.")

    # write the diff to a file
    fh = open("temp.patch", "w")
    fh.write(diff)
    fh.close()

    # apply the patch
    os.system("cp " + os.path.join(conf.path, "main.asm") + " " + os.path.join(conf.path, "main1.asm"))
    os.system("patch " + os.path.join(conf.path, "main.asm") + " " + "temp.patch")

    # remove the patch
    os.system("rm temp.patch")

    # confirm it's working
    if do_compile:
        try:
            subprocess.check_call("cd " + conf.path + "; make clean; make", shell=True)
            return True
        except Exception, exc:
            if try_fixing:
                os.system("mv " + os.path.join(conf.path, "main1.asm") + " " + os.path.join(conf.path, "main.asm"))
            return False

import crystalparts.asmline
AsmLine = crystalparts.asmline.AsmLine

class Incbin:
    def __init__(self, line, bank=None, debug=False):
        self.line = line
        self.bank = bank
        self.replace_me = False
        self.debug = debug
        self.parse()

    def parse(self):
        incbin = self.line
        partial_start = incbin[21:]
        start = partial_start.split(",")[0].replace("$", "0x")

        if self.debug:
            logging.debug("Incbin.parse line is {0}".format(self.line))
            logging.debug("Incbin.parse partial_start is {0}".format(partial_start))
            logging.debug("Incbin.parse start is {0}".format(start))
        try:
            start = eval(start)
        except Exception, e:
            logging.debug("start is {0}".format(start))
            raise Exception("problem with evaluating interval range: " + str(e))

        start_hex = hex(start).replace("0x", "$")

        partial_interval = incbin[21:].split(",")[1]
        partial_interval = partial_interval.replace(";", "#")
        partial_interval = partial_interval.replace("$", "0x").replace("0xx", "0x")
        interval = eval(partial_interval)
        interval_hex = hex(interval).replace("0x", "$").replace("x", "")

        end = start + interval
        end_hex = hex(end).replace("0x", "$")

        self.address = start
        self.start_address = start
        self.end_address = end
        self.last_address = end
        self.interval = interval

    def to_asm(self):
        if self.interval > 0:
            return self.line
        else:
            return ""

    def split(self, start_address, byte_count):
        """splits this incbin into three separate incbins"""
        if start_address < self.start_address or start_address > self.end_address:
            raise Exception("this incbin doesn't handle this address")
        incbins = []

        if self.debug:
            logging.debug(
                "splitting an incbin (\"{line}\") into three at {start} for {count} bytes"
                .format(
                    line=self.line,
                    start=hex(start_address),
                    count=byte_count,
                )
            )

        # start, end1, end2 (to be printed as start, end1 - end2)
        if (start_address - self.start_address) > 0:
            first = (self.start_address, start_address, self.start_address)
            incbins.append(Incbin("INCBIN \"baserom.gbc\",$%.2x,$%.2x - $%.2x" % (first[0], first[1], first[2])))
            if self.debug:
                logging.debug(incbins[0].line)
        else:
            # skip this one because we're not including anything
            first = None

        # this is the one you will replace with whatever content
        second = (start_address, byte_count)
        incbins.append(Incbin("INCBIN \"baserom.gbc\",$%.2x,$%.2x" % (start_address, byte_count)))
        incbins[-1].replace_me = True
        if self.debug:
            logging.debug(incbins[-1].line)

        if (self.last_address - (start_address + byte_count)) > 0:
            third = (start_address + byte_count, self.last_address - (start_address + byte_count))
            incbins.append(Incbin("INCBIN \"baserom.gbc\",$%.2x,$%.2x" % (third[0], third[1])))
            if self.debug:
                logging.debug(incbins[-1].line)

        return incbins

class AsmSection:
    def __init__(self, line):
        self.bank_id = None
        self.line = line
        self.parse()

    def parse(self):
        line    = self.line

        if not "bank" in line:
            self.bank_id      = -1
            self.address      = -1
            self.last_address = None
            self.end_address  = None
            return

        bank_id = int(line.split("\"")[1].split("bank")[1], 16)
        self.bank_id  = bank_id
        start_address = bank_id * 0x4000
        end_address   = (bank_id * 0x4000) + 0x4000 - 1

        self.address = self.start_address = start_address
        self.last_address = None
        self.end_address = None
        # this entity doesn't actually take up this space..
        # although it could be argued that lines should exist under this object
        #self.address  = self.start_address = start_address
        #self.last_address = self.end_address = end_address

    def to_asm(self):
        return self.line

new_asm = None
def load_asm2(filename=None, force=False):
    """loads the asm source code into memory"""
    if filename == None:
        filename = os.path.join(conf.path, "main.asm")
    global new_asm
    if new_asm == None or force:
        new_asm = Asm(filename=filename)
    return new_asm

class Asm:
    """controls the overall asm output"""
    def __init__(self, filename=None, debug=True):
        if filename == None:
            filename = os.path.join(conf.path, "main.asm")
        self.parts = []
        self.labels = []
        self.filename = filename
        self.debug = debug
        self.load_and_parse()

    def load_and_parse(self):
        self.parts = []
        asm = open(self.filename, "r").read().split("\n")
        asm_list = romstr.AsmList(asm)
        bank = 0
        for line in asm_list:
            if (line[0:6] == "INCBIN" or line[1:6] == "INCBIN") and not any([contaminant+"\"" in line for contaminant in [".2bpp", ".1bpp", ".asm", ".lz"]]):
                thing = Incbin(line, bank=bank)
            elif line[0:7] == "SECTION":
                thing = AsmSection(line)
                bank = thing.bank_id
            else:
                thing = AsmLine(line, bank=bank)
                label = labels.get_label_from_line(line)
                if label:
                    laddress = labels.get_address_from_line_comment(line)
                    thing.label = Label(name=label, address=laddress, object=thing, add_to_globals=False)
                    self.labels.append(thing.label)
            self.parts.append(thing)

    def is_label_name_in_file(self, label_name):
        for llabel in self.labels:
            if llabel.name == label_name:
                return llabel
        return False

    def does_address_have_label(self, address):
        """
        Checks if an address has a label.
        """
        # either something will directly have the address
        # or- it's possibel that no label was given
        # or there will be an Incbin that covers the range
        for part in self.parts:
            if isinstance(part, Incbin) and part.start_address <= address <= part.end_address:
                return False
            elif hasattr(part, "address") and part.address == address and hasattr(part, "label"):
                return part.label

        return None

    def insert(self, new_object):
        if isinstance(new_object, ScriptPointerLabelParam):
            # its' probably being injected in some get_dependencies() somewhere
            logging.debug("don't know why ScriptPointerLabelParam is getting to this point?")
            return

        # first some validation
        if not hasattr(new_object, "address"):
            logging.debug("object needs to have an address property: {0}".format(new_object))
            return

        start_address = new_object.address

        # skip this dragon shrine script calling itself
        # what about other scripts that call themselves ?
        if start_address in lousy_dragon_shrine_hack:
            logging.debug("skipping 0x18d079 in dragon shrine for a lousy hack")
            return

        if not hasattr(new_object, "label") and hasattr(new_object, "is_valid") and not new_object.is_valid():
            return

        debugmsg  = "object is " + new_object.label.name + " type="+str(new_object.__class__)+" new_object="+str(new_object)
        debugmsg += " label = " + new_object.label.name
        debugmsg += " start_address="+hex(start_address)#+" end_address="+hex(end_address)

        if not hasattr(new_object, "last_address"):
            logging.debug(debugmsg)
            raise Exception("object needs to have a last_address property")
        end_address = new_object.last_address
        debugmsg += " last_address="+hex(end_address)

        # check if the object is already inserted
        if new_object in self.parts:
            logging.debug(
                "object was previously inserted ({new_object}; {address})"
                .format(
                    new_object=new_object,
                    address=hex(new_object.address),
                )
            )
            return
        # check by label
        other_obj = self.is_label_name_in_file(new_object.label.name)
        if other_obj:
            other_obj = other_obj.object
            logging.debug(
                "object was previously inserted ({name} at {address}) by {othername} at {otheraddress}"
                .format(
                    name=new_object.label.name,
                    address=hex(new_object.address),
                    othername=other_obj.label.name,
                    otheraddress=other_obj.address,
                )
            )
            return
        # check by address
        #if self.does_address_have_label(new_object.address):
        #    print "object's address is already used ("+str(new_object)+") at "+hex(new_object.address)+" label="+new_object.label.name
        #    return

        if self.debug:
            logging.debug(debugmsg)
        del debugmsg
        if (end_address < start_address) or ((end_address - start_address) < 0):
            if not self.debug:
                logging.debug("object is new_object={0}".format(new_object))
                logging.deubg(
                    "start_address={start} end_address={end}"
                    .format(start=hex(start_address), end=hex(end_address))
                )
            if hasattr(new_object, "to_asm"):
                logging.debug(to_asm(new_object))
            raise Exception("Asm.insert was given an object with a bad address range")

        # 1) find which object needs to be replaced
        # or
        # 2) find which object goes after it
        found = False
        for object in list(self.parts):
            # skip objects without a defined interval (like a comment line)
            if not hasattr(object, "address") or not hasattr(object, "last_address"):
                continue
            # skip an AsmSection
            if isinstance(object, AsmSection):
                continue
            # replace an incbin with three incbins, replace middle incbin with whatever
            elif isinstance(object, Incbin) and (object.address <= start_address < object.last_address):
                # split up the incbin into three segments
                incbins = object.split(start_address, end_address - start_address)
                # figure out which incbin to replace with the new object
                if incbins[0].replace_me:
                    index = 0
                else: # assume incbins[1].replace_me (the middle one)
                    index = 1
                # replace that index with the new_object
                incbins[index] = new_object
                # insert these incbins into self.parts
                gindex = self.parts.index(object)
                self.parts = self.parts[:gindex] + incbins + self.parts[gindex:]
                self.parts.remove(object)
                found = True
                break
            elif object.address <= start_address < object.last_address:
                logging.debug("this is probably a script that is looping back on itself?")
                found = True
                break
            # insert before the current object
            elif object.address > end_address:
                #insert_before = index of object
                index = self.parts.index(object)
                self.parts.insert(index, new_object)
                found = True
                break
        if not found:
            raise Exception("unable to insert object into Asm")
        self.labels.append(new_object.label)
        return True

    def insert_with_dependencies(self, input):
        if type(input) == list:
            input_objects = input
        else:
            input_objects = [input]

        for object0 in input_objects:
            global_dependencies = set([object0])
            poopbutt = get_dependencies_for(object0, global_dependencies=global_dependencies, recompute=False)
            objects = global_dependencies
            objects.update(poopbutt)
            new_objects = copy(objects)
            for object in objects:
                if hasattr(object, "dependencies") and object.dependencies == None:
                    new_objects.update(object.get_dependencies())
            for object in new_objects:
                if isinstance(object, ScriptPointerLabelParam):
                    continue
                #if object in self.parts:
                #    if self.debug:
                #        print "already inserted -- object.__class__="+str(object.__class__)+" object is: "+str(object)+\
                #              " for object.__class__="+str(object0.__class__)+" object="+str(object0)
                #    continue
                if self.debug:
                    logging.debug("object is: {0}".format(object))
                self.insert(object)

                # just some old debugging
                #if object.label.name == "UnknownText_0x60128":
                #    raise Exception("debugging...")
                #elif object.label.name == "UnknownScript_0x60011":
                #    raise Exception("debugging.. dependencies are: " + str(object.dependencies) + " versus: " + str(object.get_dependencies()))

    def insert_single_with_dependencies(self, object):
        self.insert_with_dependencies(object)

    def insert_multiple_with_dependencies(self, objects):
        self.insert_with_dependencies(objects)

    def insert_all(self, limit=100):
        count = 0
        for each in script_parse_table.items():
            if count == limit: break
            object = each[1]
            if type(object) == str: continue
            self.insert_single_with_dependencies(object)
            count += 1

    def insert_and_dump(self, limit=100, filename="output.txt"):
        self.insert_all(limit=limit)
        self.dump(filename=filename)

    def dump(self, filename="output.txt"):
        fh = open(filename, "w")
        newlines_before_next_obj_requested = 0
        newlines_before_next_obj_given     = 0

        current_requested_newlines_before  = 0
        current_requested_newlines_after   = 0
        previous_requested_newlines_before = 0
        previous_requested_newlines_after  = 0

        written_newlines          = 0
        write_something           = False
        first = True
        last  = None
        for each in self.parts:
            asm = ""
            previous_requested_newlines_after = current_requested_newlines_after
            current_requested_newlines_before = current_requested_newlines_after

            write_something = True
            if (isinstance(each, str) and each == "") or (isinstance(each, AsmLine) and each.line == ""):
                current_requested_newlines_before = 0
                if current_requested_newlines_after < 2:
                    current_requested_newlines_after += 1
                write_something = False
            elif (isinstance(each, str) and each != "") or (isinstance(each, AsmLine) and each.line != ""):
                if isinstance(each, AsmLine):
                    asm = each.to_asm()
                elif isinstance(each, str):
                    asm = each
                current_requested_newlines_before = 0
                current_requested_newlines_after  = 1
            elif isinstance(each, AsmSection) or isinstance(each, Incbin) or hasattr(each, "to_asm"):
                if isinstance(each, AsmSection) or isinstance(each, Incbin):
                    asm = each.to_asm()
                else:
                    asm = to_asm(each)
                current_requested_newlines_before = 2
                current_requested_newlines_after  = 2
            else:
                raise Exception("dunno what to do with("+str(each)+") in Asm.parts")

            if write_something:
                if not first:
                    newlines_before = max([current_requested_newlines_before, previous_requested_newlines_after])
                    while written_newlines < newlines_before:
                        fh.write("\n")
                        written_newlines += 1
                else:
                    first = False
                fh.write(asm)
                written_newlines = 0
            last = each

        # make sure the file ends with a newline
        fh.write("\n")

def list_things_in_bank(bank):
    objects = []
    for blah in script_parse_table.items():
        object = blah[1]
        if hasattr(object, "address") and pointers.calculate_bank(object.address) == bank:
            objects.append(object)
    return objects

def list_texts_in_bank(bank):
    """
    Narrows down the list of objects that you will be inserting into Asm.
    """
    if len(all_texts) == 0:
        raise Exception("all_texts is blank.. parse_rom() will populate it")

    assert bank != None, "list_texts_in_banks must be given a particular bank"

    assert 0 <= bank < 0x80, "bank doesn't exist in the ROM"

    texts = []
    for text in all_texts:
        if pointers.calculate_bank(text.address) == bank:
            texts.append(text)

    return texts

def list_movements_in_bank(bank, all_movements):
    """
    Narrows down the list of objects to speed up Asm insertion.
    """
    if len(all_movements) == 0:
        raise Exception("all_movements is blank.. parse_rom() will populate it")

    assert bank != None, "list_movements_in_bank must be given a particular bank"
    assert 0 <= bank < 0x80, "bank doesn't exist in the ROM (out of bounds)"

    movements = []
    for movement in all_movements:
        if pointers.calculate_bank(movement.address) == bank:
            movements.append(movement)
    return movements

def dump_asm_for_texts_in_bank(bank, start=50, end=100, rom=None):
    """
    Simple utility to help with dumping texts into a particular bank. This is
    helpful for figuring out which text is breaking that bank.
    """
    # load and parse the ROM if necessary
    if rom == None or len(rom) <= 4:
        rom = load_rom()
        parse_rom()

    # get all texts
    # first 100 look okay?
    texts = list_texts_in_bank(bank)[start:end]

    # create a new dump
    asm = Asm()

    # start the insertion process
    asm.insert_multiple_with_dependencies(texts)

    # start dumping
    asm.dump()

    logging.info("done dumping texts for bank {banked}".format(banked="$%.2x" % bank))

def dump_asm_for_movements_in_bank(bank, start=0, end=100, all_movements=None):
    if rom == None or len(rom) <= 4:
        rom = load_rom()
        parse_rom()

    movements = list_movements_in_bank(bank, all_movements)[start:end]

    asm = Asm()
    asm.insert_with_dependencies(movements)
    asm.dump()
    logging.info("done dumping movements for bank {banked}".format(banked="$%.2x" % bank))

def dump_things_in_bank(bank, start=50, end=100):
    """
    is helpful for figuring out which object is breaking that bank.
    """
    # load and parse the ROM if necessary
    if rom == None or len(rom) <= 4:
        rom = load_rom()
        parse_rom()

    things = list_things_in_bank(bank)[start:end]

    # create a new dump
    asm = Asm()

    # start the insertion process
    asm.insert_with_dependencies(things)

    # start dumping
    asm.dump()

    logging.info("done dumping things for bank {banked}".format(banked="$%.2x" % bank))

def analyze_intervals():
    """find the largest baserom.gbc intervals"""
    global asm, processed_incbins
    if asm == None:
        load_asm()
    if processed_incbins == {}:
        isolate_incbins(asm=asm)
        process_incbins()
    results = []
    ordered_keys = sorted(processed_incbins, key=lambda entry: processed_incbins[entry]["interval"])
    ordered_keys.reverse()
    for key in ordered_keys:
        results.append(processed_incbins[key])
    return results

all_labels = []
def write_all_labels(all_labels, filename="labels.json"):
    fh = open(filename, "w")
    fh.write(json.dumps(all_labels))
    fh.close()
    return True

def setup_wram_labels(config=conf):
    """
    Get all wram labels and store it on the module.
    """
    wramproc = wram.WRAMProcessor(config=config)
    wramproc.initialize()
    wram.wram_labels = wramproc.wram_labels

def get_ram_label(address):
    """
    returns a label assigned to a particular ram address
    """
    if not hasattr(wram, "wram_labels"):
        setup_wram_labels()
    if address in wram.wram_labels.keys():
        return wram.wram_labels[address][-1]
    return None

def get_label_for(address):
    """
    returns a label assigned to a particular address
    """
    global all_labels

    if address == None:
        return None
    if type(address) != int:
        raise Exception("get_label_for requires an integer address, got: " + str(type(address)))

    # lousy hack to get around recursive scripts in dragon shrine
    if address in lousy_dragon_shrine_hack:
        return None

    # the old way
    for thing in all_labels:
        if thing["address"] == address:
            return thing["label"]

    # the new way
    obj = script_parse_table[address]
    if obj:
        if hasattr(obj, "label"):
            return obj.label.name
        else:
            return "AlreadyParsedNoDefaultUnknownLabel_" + hex(address)

    return None

# all_new_labels is a temporary replacement for all_labels,
# at least until the two approaches are merged in the code base.
all_new_labels = []

class Label:
    """
    Every object in script_parse_table is given a label.

    This label is simply a way to keep track of what objects have
    been previously written to file.
    """
    def __init__(self, name=None, address=None, line_number=None, object=None, is_in_file=None, address_is_in_file=None, add_to_globals=True):
        assert address != None, "need an address"
        assert is_valid_address(address), "address must be valid"
        assert object != None, "need an object to relate with"

        self.address = address
        self.object = object

        # label might not be in the file yet
        self.line_number = line_number

        # -- These were some old attempts to check whether the label
        # -- was already in use. They work, but the other method is
        # -- better.
        #
        # check if the label is in the file already
        # check if the address of this label is already in use

        self.is_in_file = is_in_file

        self.address_is_in_file = address_is_in_file

        if name == None:
            name = object.base_label + "_" + hex(object.address)

        self.name = name

        if add_to_globals:
            all_new_labels.append(self)

    def check_is_in_file(self):
        """
        This method checks if the label appears in the file based on the
        entries to the Asm.parts list.
        """
        # assert new_asm != None, "new_asm should be an instance of Asm"
        new_asm = load_asm2()
        is_in_file = new_asm.is_label_name_in_file(self.name)
        self.is_in_file = is_in_file
        return is_in_file

    def check_address_is_in_file(self):
        """
        Checks if the address is in use by another label.
        """
        new_asm = load_asm2()
        self.address_is_in_file = new_asm.does_address_have_label(self.address)
        return self.address_is_in_file

    def old_check_address_is_in_file(self):
        """
        Checks whether or not the address of the object is already in the file.
        This might happen if the label name is different but the address is the
        same. Another scenario is that the label is already used, but at a
        different address.

        This method works by looking at the INCBINs. When there is
        an INCBIN that covers this address in the file, then there
        is no label at this address yet (or there is, but we can
        easily add another label in front of the incbin or something),
        and when there is no INCBIN that has this address, then we
        know that something is already using this address.
        """
        if processed_incbins == {}:
            process_incbins()

        incbin = find_incbin_to_replace_for(self.address)

        if incbin == None:
            return True
        else:
            return False

    def make_label(self):
        """
        Generates a label name based on parents and self.object.
        """
        obj = self.object
        name = obj.make_label()
        return name

label_errors = ""
def get_labels_between(start_line_id, end_line_id, bank):
    foundlabels = []
    #label = {
    #   "line_number": 15,
    #   "bank": 32,
    #   "label": "PalletTownText1",
    #   "offset": 0x5315,
    #   "address": 0x75315,
    #}
    if asm == None:
        load_asm()
    sublines = asm[start_line_id : end_line_id + 1]
    for (current_line_offset, line) in enumerate(sublines):
        # skip lines without labels
        if not labels.line_has_label(line): continue
        # reset some variables
        line_id = start_line_id + current_line_offset
        line_label = labels.get_label_from_line(line)
        address = None
        offset = None
        # setup a place to store return values from line_has_comment_address
        returnable = {}
        # get the address from the comment
        has_comment = labels.line_has_comment_address(line, returnable=returnable, bank=bank)
        # skip this line if it has no address in the comment
        if not has_comment: continue
        # parse data from line_has_comment_address
        address = returnable["address"]
        bank = returnable["bank"]
        offset = returnable["offset"]
        # dump all this info into a single structure
        label = {
            "line_number": line_id,
            "bank": bank,
            "label": line_label,
            "offset": offset,
            "address": address,
        }
        # store this structure
        foundlabels.append(label)
    return foundlabels

def scan_for_predefined_labels(debug=False):
    """looks through the asm file for labels at specific addresses,
    this relies on the label having its address after. ex:

    ViridianCity_h: ; 0x18357 to 0x18384 (45 bytes) (bank=6) (id=1)
    PalletTownText1: ; 4F96 0x18f96
    ViridianCityText1: ; 0x19102

    It would be more productive to use rgbasm to spit out all label
    addresses, but faster to write this script. rgbasm would be able
    to grab all label addresses better than this script..
    """
    global all_labels
    all_labels = []
    bank_intervals = {}

    if asm == None:
        load_asm()

    # figure out line numbers for each bank
    for bank_id in range(0x7F+1):
        abbreviation = ("%.x" % (bank_id)).upper()
        abbreviation_next = ("%.x" % (bank_id+1)).upper()
        if bank_id == 0:
            abbreviation = "0"
            abbreviation_next = "1"

        # calculate the start/stop line numbers for this bank
        start_line_id = helpers.index(asm, lambda line: "\"bank" + abbreviation.lower() + "\"" in line.lower())
        if bank_id != 0x7F:
            end_line_id = helpers.index(asm, lambda line: "\"bank" + abbreviation_next.lower() + "\"" in line.lower())
            end_line_id += 1
        else:
            end_line_id = len(asm) - 1

        if debug:
            output = "bank" + abbreviation + " starts at "
            output += str(start_line_id)
            output += " to "
            output += str(end_line_id)
            logging.debug(output)

        # store the start/stop line number for this bank
        bank_intervals[bank_id] = {"start": start_line_id,
                                   "end": end_line_id,}
    # for each bank..
    for bank_id in bank_intervals.keys():
        # get the start/stop line number
        bank_data = bank_intervals[bank_id]
        start_line_id = bank_data["start"]
        end_line_id   = bank_data["end"]
        # get all labels between these two lines
        labels = get_labels_between(start_line_id, end_line_id, bank_id)
        # bank_intervals[bank_id]["labels"] = labels
        all_labels.extend(labels)
    write_all_labels(all_labels)
    return all_labels

all_map_headers = []

trainer_group_maximums = {}

# Some of the commands need a reference to this data. This is a hacky way to
# get around having a global, and it should be fixed eventually.
Command.trainer_group_maximums = trainer_group_maximums

SingleByteParam.map_internal_ids = map_internal_ids
MultiByteParam.map_internal_ids = map_internal_ids

def add_map_offsets_into_map_names(map_group_offsets, map_names=None):
    """
    Add the offsets for each map into the map_names variable.
    """
    # add the offsets into our map structure, why not (johto maps only)
    return [map_names[map_group_id+1].update({"offset": offset}) for map_group_id, offset in enumerate(map_group_offsets)]

rom_parsed = False

def parse_rom(rom=None):
    if not rom:
        # read the rom and figure out the offsets for maps
        rom = direct_load_rom()

    # make wram.wram_labels available
    setup_wram_labels()

    # figure out the map offsets
    map_group_offsets = load_map_group_offsets(map_group_pointer_table=map_group_pointer_table, map_group_count=map_group_count, rom=rom)

    # populate the map_names structure with the offsets
    add_map_offsets_into_map_names(map_group_offsets, map_names=map_names)

    # parse map header bytes for each map
    parse_all_map_headers(map_names, all_map_headers=all_map_headers)

    # find trainers based on scripts and map headers
    # this can only happen after parsing the entire map and map scripts
    find_trainer_ids_from_scripts(script_parse_table=script_parse_table, trainer_group_maximums=trainer_group_maximums)

    # and parse the main TrainerGroupTable once we know the max number of trainers
    #global trainer_group_table
    trainer_group_table = TrainerGroupTable(trainer_group_maximums=trainer_group_maximums, trainers=trainers, script_parse_table=script_parse_table)

    # improve duplicate trainer names
    make_trainer_group_name_trainer_ids(trainer_group_table)

    global rom_parsed
    rom_parsed = True

    return map_names

def cachably_parse_rom(rom=None):
    """
    Calls parse_rom if it hasn't been called and completed yet.
    """
    global rom_parsed
    if not rom_parsed:
        return parse_rom(rom=rom)
    else:
        return map_names

if __name__ == "crystal":
    pass
