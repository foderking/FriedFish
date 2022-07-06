#!/usr/bin/python3
import sys, re

def transform(num):
    return f"{int(num[:-3]):#0{18}x}".upper().replace("X", "x")+"u64"

def trans(num):
    return f"{int(num.group()[:-3]):#0{18}x}".upper().replace("X", "x")+"u64"

def change(s):
    return re.sub(f"\d+u64", trans, s)

s = """  assertBitboard(lTable.getWestRay(A5), 0u64, "wrong value for west ray A5", debug)
  assertBitboard(lTable.getWestRay(B5), 4294967296u64, "wrong value for west ray B5", debug)
  assertBitboard(lTable.getWestRay(C5), 12884901888u64, "wrong value for west ray C5", debug)
  assertBitboard(lTable.getWestRay(D5), 30064771072u64, "wrong value for west ray D5", debug)
  assertBitboard(lTable.getWestRay(E5), 64424509440u64, "wrong value for west ray E5", debug)
  assertBitboard(lTable.getWestRay(F5), 133143986176u64, "wrong value for west ray F5", debug)
  assertBitboard(lTable.getWestRay(G5), 270582939648u64, "wrong value for west ray G5", debug)
  assertBitboard(lTable.getWestRay(H5), 545460846592u64, "wrong value for west ray H5", debug)
  assertBitboard(lTable.getWestRay(A6), 0u64, "wrong value for west ray A6", debug)
  assertBitboard(lTable.getWestRay(B6), 1099511627776u64, "wrong value for west ray B6", debug)
  assertBitboard(lTable.getWestRay(C6), 3298534883328u64, "wrong value for west ray C6", debug)
  assertBitboard(lTable.getWestRay(D6), 7696581394432u64, "wrong value for west ray D6", debug)
  assertBitboard(lTable.getWestRay(E6), 16492674416640u64, "wrong value for west ray E6", debug)
  assertBitboard(lTable.getWestRay(F6), 34084860461056u64, "wrong value for west ray F6", debug)
  assertBitboard(lTable.getWestRay(G6), 69269232549888u64, "wrong value for west ray G6", debug)
  assertBitboard(lTable.getWestRay(H6), 139637976727552u64, "wrong value for west ray H6", debug)
  assertBitboard(lTable.getWestRay(A7), 0u64, "wrong value for west ray A7", debug)
  assertBitboard(lTable.getWestRay(B7), 281474976710656u64, "wrong value for west ray B7", debug)
  assertBitboard(lTable.getWestRay(C7), 844424930131968u64, "wrong value for west ray C7", debug)
  assertBitboard(lTable.getWestRay(D7), 1970324836974592u64, "wrong value for west ray D7", debug)
  assertBitboard(lTable.getWestRay(E7), 4222124650659840u64, "wrong value for west ray E7", debug)
  assertBitboard(lTable.getWestRay(F7), 8725724278030336u64, "wrong value for west ray F7", debug)
  assertBitboard(lTable.getWestRay(G7), 17732923532771328u64, "wrong value for west ray G7", debug)
  assertBitboard(lTable.getWestRay(H7), 35747322042253312u64, "wrong value for west ray H7", debug)
  assertBitboard(lTable.getWestRay(A8), 0u64, "wrong value for west ray A8", debug)
  assertBitboard(lTable.getWestRay(B8), 72057594037927936u64, "wrong value for west ray B8", debug)
  assertBitboard(lTable.getWestRay(C8), 216172782113783808u64, "wrong value for west ray C8", debug)
  assertBitboard(lTable.getWestRay(D8), 504403158265495552u64, "wrong value for west ray D8", debug)
  assertBitboard(lTable.getWestRay(E8), 1080863910568919040u64, "wrong value for west ray E8", debug)
  assertBitboard(lTable.getWestRay(F8), 2233785415175766016u64, "wrong value for west ray F8", debug)
  assertBitboard(lTable.getWestRay(G8), 4539628424389459968u64, "wrong value for west ray G8", debug)
  assertBitboard(lTable.getWestRay(H8), 9151314442816847872u64, "wrong value for west ray H8", debug)"""

if len(sys.argv)==2:
    print(transform(sys.argv[1]))
else:
    print(change(s))
