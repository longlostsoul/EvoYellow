# -*- coding: utf-8 -*-
"""
Find shared functions between red/crystal.
"""

from crystal import (
    get_label_from_line,
    get_address_from_line_comment,
    AsmSection,
    direct_load_rom,
    direct_load_asm,
)

from romstr import (
    RomStr,
    AsmList,
)

def load_rom(path):
    """
    Load a ROM file into an abbreviated RomStr object.
    """
    return direct_load_rom(filename=path)

def load_asm(path):
    """
    Load source ASM into an abbreviated AsmList object.
    """
    return direct_load_asm(filename=path)

def findall_iter(sub, string):
    # url: http://stackoverflow.com/a/3874760/687783

    def next_index(length):
        index = 0 - length
        while True:
            index = string.find(sub, index + length)
            yield index

    return iter(next_index(len(sub)).next, -1)

class Address(int):
    """
    A simple int wrapper to take 0xFFFF and $FFFF addresses.
    """

    def __new__(cls, x=None, *args, **kwargs):
        if type(x) == str:
            if "$" in x:
                x = x.replace("$", "0x")

            if "0x" in str:
                instance = int.__new__(cls, int(x, base=16), *args, **kwargs)
            else:
                msg = "Address.__new__ doesn't know how to parse this string"
                raise Exception, msg
        else:
            instance = int.__new__(cls, x, *args, **kwargs)

        return instance

found_blobs = []

class BinaryBlob(object):
    """
    Store a label, line number, and addresses of a function from Pokémon Red.

    These details can be used to determine whether or not the function was
    copied into Pokémon Crystal.
    """

    start_address = None
    end_address   = None
    label         = None
    line_number   = None
    bytes         = None
    bank          = None
    debug         = False
    locations     = None

    def __init__(self, start_address=None, end_address=None, label=None, \
                 debug=None, line_number=None):
        if not isinstance(start_address, Address):
            start_address = Address(start_address)
        if not isinstance(end_address, Address):
            end_address   = Address(end_address)

        assert label != None,          "label can't be none"
        assert isinstance(label, str), "label must be a string"
        assert line_number != None,    "line_number must be provided"

        self.start_address = start_address
        self.end_address   = end_address
        self.label         = label
        self.line_number   = line_number
        self.bytes         = []
        self.locations     = []
        self.bank          = start_address / 0x4000

        if debug != None:
            self.debug = debug

        self.parse_from_red()
        # self.find_in_crystal()
        self.find_by_first_bytes()

    def __repr__(self):
        """
        A beautiful poem.
        """

        r = "BinaryBlob("
        r += "label=\""+self.label+"\", "
        r += "start_address="+hex(self.start_address)+", "
        r += "size="+str(self.end_address - self.start_address)+", "
        locnum = len(self.locations)
        if locnum == 1:
            r += "located="+hex(self.locations[0])
        elif locnum <= 5:
            r += "located="+str([hex(x) for x in self.locations])
        else:
            r += "located="+str(locnum)
        r += ")"

        return r

    def __str__(self):
        return self.__repr__()

    def parse_from_red(self):
        """
        Read bytes from Pokémon Red and stores them.
        """

        self.bytes = redrom[self.start_address : self.end_address + 1]

    def pretty_bytes(self):
        """
        Returns a better looking range of bytes.
        """

        bytes = redrom.interval(self.start_address,    \
                self.end_address - self.start_address, \
                strings=False, debug=True)

        return bytes

    def find_in_crystal(self):
        """
        Check whether or not the bytes appear in Pokémon Crystal.
        """

        finditer       = findall_iter(self.bytes, cryrom)
        self.locations = [match for match in finditer]

        if len(self.locations) > 0:
            found_blobs.append(self)

            if self.debug:
                print self.label + ": found " + str(len(self.locations)) + " matches."

    def find_by_first_bytes(self):
        """
        Find this blob in Crystal based on the first n bytes.
        """

        # how many bytes to match
        first_n = 3

        # no match
        if len(self.bytes) <= first_n:
            return

        finditer       = findall_iter(self.bytes[0:first_n], cryrom)
        self.locations = [match for match in finditer]

        # filter out locations that suck
        self.locations = [i for i in self.locations if abs(self.start_address - i) <= 0x8000]

        if len(self.locations) > 0:
            found_blobs.append(self)

            if self.debug:
                print self.label + ": found " + str(len(self.locations)) + " matches."

pokecrystal_rom_path = "../baserom.gbc"
pokecrystal_src_path = "../main.asm"
pokered_rom_path     = "../pokered-baserom.gbc"
pokered_src_path     = "../pokered-main.asm"

cryrom           = load_rom(pokecrystal_rom_path)
crysrc           = load_asm(pokecrystal_src_path)
redrom           = load_rom(pokered_rom_path)
redsrc           = load_asm(pokered_src_path)

def scan_red_asm(bank_stop=3, debug=True):
    """
    Scan the ASM from Pokémon Red. Finds labels and objects. Does things.

    Uses get_label_from_line and get_address_from_line_comment.
    """

    # whether or not to show the lines from redsrc
    show_lines            = False

    line_number           = 0
    current_bank          = 0

    current_label         = None
    latest_label          = "ignore me"
    current_start_address = None
    latest_start_address  = 0
    latest_line           = ""

    for line in redsrc:
        if debug and show_lines:
            print "processing a line from red: " + line

        if line[0:7] == "SECTION":
            thing        = AsmSection(line)
            current_bank = thing.bank_id

            if debug:
                print "scan_red_asm: switching to bank " + str(current_bank)

        elif line[0:6] != "INCBIN":
            if ":" in line and not ";XXX:" in line and not " ; XXX:" in line:
                current_label         = get_label_from_line(line)
                current_start_address = get_address_from_line_comment(line, \
                                        bank=current_bank)

                if current_label != None and current_start_address != None and latest_start_address != None \
                   and current_start_address != 0 and current_start_address != latest_start_address \
                   and (current_start_address - latest_start_address) > 1:
                    if latest_label != None:
                        if latest_label not in ["Char52", "PokeCenterSignText", "DefaultNamesPlayer", "Unnamed_6a12"]:
                            blob = BinaryBlob(label=latest_label,      \
                                   start_address=latest_start_address, \
                                   end_address=current_start_address,  \
                                   line_number=line_number)

                            if debug:
                                print "Created a new blob: " + str(blob) + " from line: " + str(latest_line)

                    latest_label          = current_label
                    latest_start_address  = current_start_address
                    latest_line           = line

        line_number += 1

        if current_bank == bank_stop:
            if debug:
                print "scan_red_asm: stopping because current_bank >= " + \
                      str(bank_stop) + " (bank_stop)"

            break

scan_red_asm(bank_stop=3)

print "================================"

for blob in found_blobs:
    print blob

print "Found " + str(len(found_blobs)) + " possibly copied functions."

print [hex(x) for x in found_blobs[10].locations]
