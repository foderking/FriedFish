#!/usr/bin/python3
import sys, re

def transform(num):
    return f"{int(num[:-3]):#0{18}x}".upper().replace("X", "x")+"u64"

def trans(num):
    return f"{int(num.group()[:-3]):#0{18}x}".upper().replace("X", "x")+"u64"

def change(s):
    return re.sub(f"\d+u64", trans, s)

s = """  assertBitboard(lTable.getSouthWestRay(A5), 0u64, "wrong value for south-west ray at A5")
  assertBitboard(lTable.getSouthWestRay(B5), 16777216u64, "wrong value for south-west ray at B5")
  assertBitboard(lTable.getSouthWestRay(C5), 33619968u64, "wrong value for south-west ray at C5")
  assertBitboard(lTable.getSouthWestRay(D5), 67240192u64, "wrong value for south-west ray at D5")
  assertBitboard(lTable.getSouthWestRay(E5), 134480385u64, "wrong value for south-west ray at E5")
  assertBitboard(lTable.getSouthWestRay(F5), 268960770u64, "wrong value for south-west ray at F5")
  assertBitboard(lTable.getSouthWestRay(G5), 537921540u64, "wrong value for south-west ray at G5")
  assertBitboard(lTable.getSouthWestRay(H5), 1075843080u64, "wrong value for south-west ray at H5")
  assertBitboard(lTable.getSouthWestRay(A6), 0u64, "wrong value for south-west ray at A6")
  assertBitboard(lTable.getSouthWestRay(B6), 4294967296u64, "wrong value for south-west ray at B6")
  assertBitboard(lTable.getSouthWestRay(C6), 8606711808u64, "wrong value for south-west ray at C6")
  assertBitboard(lTable.getSouthWestRay(D6), 17213489152u64, "wrong value for south-west ray at D6")
  assertBitboard(lTable.getSouthWestRay(E6), 34426978560u64, "wrong value for south-west ray at E6")
  assertBitboard(lTable.getSouthWestRay(F6), 68853957121u64, "wrong value for south-west ray at F6")
  assertBitboard(lTable.getSouthWestRay(G6), 137707914242u64, "wrong value for south-west ray at G6")
  assertBitboard(lTable.getSouthWestRay(H6), 275415828484u64, "wrong value for south-west ray at H6")
  assertBitboard(lTable.getSouthWestRay(A7), 0u64, "wrong value for south-west ray at A7")
  assertBitboard(lTable.getSouthWestRay(B7), 1099511627776u64, "wrong value for south-west ray at B7")
  assertBitboard(lTable.getSouthWestRay(C7), 2203318222848u64, "wrong value for south-west ray at C7")
  assertBitboard(lTable.getSouthWestRay(D7), 4406653222912u64, "wrong value for south-west ray at D7")
  assertBitboard(lTable.getSouthWestRay(E7), 8813306511360u64, "wrong value for south-west ray at E7")
  assertBitboard(lTable.getSouthWestRay(F7), 17626613022976u64, "wrong value for south-west ray at F7")
  assertBitboard(lTable.getSouthWestRay(G7), 35253226045953u64, "wrong value for south-west ray at G7")
  assertBitboard(lTable.getSouthWestRay(H7), 70506452091906u64, "wrong value for south-west ray at H7")
  assertBitboard(lTable.getSouthWestRay(A8), 0u64, "wrong value for south-west ray at A8")
  assertBitboard(lTable.getSouthWestRay(B8), 281474976710656u64, "wrong value for south-west ray at B8")
  assertBitboard(lTable.getSouthWestRay(C8), 564049465049088u64, "wrong value for south-west ray at C8")
  assertBitboard(lTable.getSouthWestRay(D8), 1128103225065472u64, "wrong value for south-west ray at D8")
  assertBitboard(lTable.getSouthWestRay(E8), 2256206466908160u64, "wrong value for south-west ray at E8")
  assertBitboard(lTable.getSouthWestRay(F8), 4512412933881856u64, "wrong value for south-west ray at F8")
  assertBitboard(lTable.getSouthWestRay(G8), 9024825867763968u64, "wrong value for south-west ray at G8")
  assertBitboard(lTable.getSouthWestRay(H8), 18049651735527937u64, "wrong value for south-west ray at H8")"""

if len(sys.argv)==2:
    print(transform(sys.argv[1]))
else:
    print(change(s))
