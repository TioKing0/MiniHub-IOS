# MiniHub Legacy Web Client

Cliente mínimo para iPad mini 1 / iOS 9 / ARMv7. Abre `http://webminihub.local` em UIWebView fullscreen.

## Build pretendido

Theos + toolchain ARMv7 em dispositivo iOS 9 jailbroken (ou ambiente Theos legado equivalente).

Requisitos históricos documentados: LLVM/Clang iOS Toolchain, ldid, make/Theos e SDK compatível.

No diretório do projeto:

    export THEOS=/var/theos
    make clean
    make
    make package

A instalação final pode ser feita via pacote Theos ou copiando o .app produzido para o dispositivo conforme o ambiente jailbreak usado.

Este projeto não contém modo demo nem dados falsos.

