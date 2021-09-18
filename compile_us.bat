TextPet.exe run-script "generateCompressedText.tps"
TextPet.exe run-script "generateText.tps"
TextPet.exe run-script "generateCompressedText_JP.tps"
TextPet.exe run-script "generateText_JP.tps"

PixelPet.exe run-script "generateImages.pps"
armips compile.asm -sym "MEGAMAN6_FXX_BR6E00.sym" -equ _version 0