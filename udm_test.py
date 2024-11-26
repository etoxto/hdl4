# -*- coding:utf-8 -*-
from __future__ import division

import udm
from udm import *

udm = udm('COM17', 921600)
print("")

CSR_LED_ADDR    = 0x00000000
CSR_SW_ADDR     = 0x00000004
TESTMEM_ADDR    = 0x80000000

CSR_INPUT_ARRAY0  = 0x00000008
CSR_INPUT_ARRAY1  = 0x0000000C
CSR_INPUT_ARRAY2  = 0x00000010
CSR_INPUT_ARRAY3  = 0x00000014
CSR_INPUT_ARRAY4  = 0x00000018
CSR_INPUT_ARRAY5  = 0x0000001C
CSR_INPUT_ARRAY6  = 0x00000020
CSR_INPUT_ARRAY7  = 0x00000024

CSR_OUTPUT_ARRAY0 = 0x00000028
CSR_OUTPUT_ARRAY1 = 0x0000002C
CSR_OUTPUT_ARRAY2 = 0x00000030
CSR_OUTPUT_ARRAY3 = 0x00000034
CSR_OUTPUT_ARRAY4 = 0x00000038
CSR_OUTPUT_ARRAY5 = 0x0000003C
CSR_OUTPUT_ARRAY6 = 0x00000040
CSR_OUTPUT_ARRAY7 = 0x00000044

CSR_START_SORT    = 0x00000048
CSR_RESULT_VALID  = 0x0000004C


def convert_32bit_to_signed(decimal_number):

    if decimal_number & 0x80000000:  # ѕровер€ем старший (31-й) бит
        # „исло отрицательное, примен€ем преобразование дополнени€ до 2
        signed_number = decimal_number - 0x100000000
    else:
        # „исло положительное, возвращаем как есть
        signed_number = decimal_number

    return signed_number


udm.wr32(CSR_LED_ADDR, 0xaa55)

udm.wr32(CSR_INPUT_ARRAY0, 0)
udm.wr32(CSR_INPUT_ARRAY1, -111)
udm.wr32(CSR_INPUT_ARRAY2, 234)
udm.wr32(CSR_INPUT_ARRAY3, 100)
udm.wr32(CSR_INPUT_ARRAY4, 363455)
udm.wr32(CSR_INPUT_ARRAY5, 2525)
udm.wr32(CSR_INPUT_ARRAY6, -1)
udm.wr32(CSR_INPUT_ARRAY7, 6)
udm.wr32(CSR_START_SORT, 1)

print(convert_32bit_to_signed(udm.rd32(CSR_OUTPUT_ARRAY0)))
print(convert_32bit_to_signed(udm.rd32(CSR_OUTPUT_ARRAY1)))
print(convert_32bit_to_signed(udm.rd32(CSR_OUTPUT_ARRAY2)))
print(convert_32bit_to_signed(udm.rd32(CSR_OUTPUT_ARRAY3)))
print(convert_32bit_to_signed(udm.rd32(CSR_OUTPUT_ARRAY4)))
print(convert_32bit_to_signed(udm.rd32(CSR_OUTPUT_ARRAY5)))
print(convert_32bit_to_signed(udm.rd32(CSR_OUTPUT_ARRAY6)))
print(convert_32bit_to_signed(udm.rd32(CSR_OUTPUT_ARRAY7)))

print("\nnew test\n")

udm.wr32(CSR_INPUT_ARRAY0, 0)
udm.wr32(CSR_INPUT_ARRAY1, 111)
udm.wr32(CSR_INPUT_ARRAY2, -234)
udm.wr32(CSR_INPUT_ARRAY3, -100)
udm.wr32(CSR_INPUT_ARRAY4, 363455)
udm.wr32(CSR_INPUT_ARRAY5, 2525)
udm.wr32(CSR_INPUT_ARRAY6, -1)
udm.wr32(CSR_INPUT_ARRAY7, 6)

print(convert_32bit_to_signed(udm.rd32(CSR_OUTPUT_ARRAY0)))
print(convert_32bit_to_signed(udm.rd32(CSR_OUTPUT_ARRAY1)))
print(convert_32bit_to_signed(udm.rd32(CSR_OUTPUT_ARRAY2)))
print(convert_32bit_to_signed(udm.rd32(CSR_OUTPUT_ARRAY3)))
print(convert_32bit_to_signed(udm.rd32(CSR_OUTPUT_ARRAY4)))
print(convert_32bit_to_signed(udm.rd32(CSR_OUTPUT_ARRAY5)))
print(convert_32bit_to_signed(udm.rd32(CSR_OUTPUT_ARRAY6)))
print(convert_32bit_to_signed(udm.rd32(CSR_OUTPUT_ARRAY7)))

udm.disconnect()