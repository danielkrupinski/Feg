format PE console 6.0
entry start

include 'INCLUDE/win32ax.inc'

struct PROCESSENTRY32
       dwSize                  dd ?
       cntUsage                dd ?
       th32ProcessID           dd ?
       th32DefaultHeapID       dd ?
       th32ModuleID            dd ?
       cntThreads              dd ?
       th32ParentProcessID     dd ?
       pcPriClassBase          dd ?
       dwFlags                 dd ?
       szExeFile               dw MAX_PATH dup (?)
ends

struct MODULEENTRY32
       dwSize                  dd ?
       th32ModuleID            dd ?
       th32ProcessID           dd ?
       GlblcntUsage            dd ?
       ProccntUsage            dd ?
       modBaseAddr             dd ?
       modBaseSize             dd ?
       hModule                 dd ?
       szModule                dw 256 dup (?)
       szExeFile               dw MAX_PATH dup (?)
ends

struct CLIENT_ID
       UniqueProcess dd ?
       UniqueThread  dd ?
ends

struct OBJECT_ATTRIBUTES
       Length                      dd ?
       RootDirectory               dd ?
       ObjectName                  dd ?
       Attributes                  dd ?
       SecurityDescriptor          dd ?
       SecurityQualityOfService    dd ?
ends

struct GLOW
		EntityPointer dd ?
        Color_r dd ?
        Color_g dd ?
        Color_b dd ?
        Color_a dd ?
        Pad db 16 dup (?)
        Occluded db ?
        Unoccluded db ?
ends

section '.text' code executable

start:
    stdcall findProcessId
    mov [clientId.UniqueProcess], eax
    stdcall findModuleBase, eax
    mov [clientBase], eax
    mov [objectAttributes.Length], sizeof.OBJECT_ATTRIBUTES
    lea eax, [processHandle]
    lea ebx, [objectAttributes]
    lea ecx, [clientId]
    invoke NtOpenProcess, eax, PROCESS_VM_READ + PROCESS_VM_WRITE + PROCESS_VM_OPERATION, ebx, ecx
    test eax, eax
    jnz exit

glow:
    lea eax, [sleepDuration]
    invoke NtDelayExecution, FALSE, eax
    mov eax, [clientBase]
    add eax, [localPlayerOffset]
    lea ebx, [localPlayer]
    invoke NtReadVirtualMemory, [processHandle], eax, ebx, 4, NULL
    test eax, eax
    jnz exit
    mov eax, [clientBase]
    add eax, [glowObjectManagerOffset]
    lea ebx, [glowObjectManager]
    invoke NtReadVirtualMemory, processHandle, eax, ebx, 4, NULL
    xor eax, eax
    loop1:
        inc eax
        push eax
        mov ecx, 0x10
        mul ecx
        add eax, [clientBase]
        add eax, [entityListOffset]
        lea ebx, [entity]
        invoke NtReadVirtualMemory, [processHandle], eax, ebx, 4, NULL
        mov eax, [entity]
        add eax, [glowIndexOffset]
        lea ebx, [glowIndex]
        invoke NtReadVirtualMemory, [processHandle], eax, ebx, 4, NULL
        mov eax, [glowIndex]
        mov ecx, 0x38
        mul ecx
        add eax, [glowObjectManager]
        lea ebx, [glowEntity]
        invoke NtReadVirtualMemory, [processHandle], eax, ebx, sizeof.GLOW, NULL
        mov [glowEntity.Color_r], 0x3f800000
        mov [glowEntity.Color_g], 0x00000000
        mov [glowEntity.Color_b], 0x00000000
        mov [glowEntity.Color_a], 0x00000000
        mov [glowEntity.Occluded], 1
        mov [glowEntity.Unoccluded], 0
        mov eax, [glowIndex]
        mov ecx, 0x38
        mul ecx
        add eax, [glowObjectManager]
        lea ebx, [glowEntity]
        invoke NtWriteVirtualMemory, [processHandle], eax, ebx, sizeof.GLOW, NULL
        pop eax
        cmp eax, 64
        jb loop1
    jmp glow

exit:
    invoke NtTerminateProcess, NULL, 0

proc findProcessId
    locals
        processEntry PROCESSENTRY32 ?
        snapshot dd ?
    endl

    invoke CreateToolhelp32Snapshot, 0x2, 0
    mov [snapshot], eax
    mov [processEntry.dwSize], sizeof.PROCESSENTRY32
    lea eax, [processEntry]
    invoke Process32First, [snapshot], eax
    cmp eax, 1
    jne exit
    loop2:
        lea eax, [processEntry]
        invoke Process32Next, [snapshot], eax
        cmp eax, 1
        jne exit
        lea eax, [processEntry.szExeFile]
        cinvoke strcmp, <'csgo.exe', 0>, eax
        test eax, eax
        jnz loop2

    mov eax, [processEntry.th32ProcessID]
    ret
endp

proc findModuleBase, processID
    locals
        moduleEntry MODULEENTRY32 ?
        snapshot dd ?
    endl

    invoke CreateToolhelp32Snapshot, 0x8, [processID]
    mov [snapshot], eax
    mov [moduleEntry.dwSize], sizeof.MODULEENTRY32
    lea eax, [moduleEntry]
    invoke Module32First, [snapshot], eax
    cmp eax, 1
    jne exit
    loop3:
        lea eax, [moduleEntry]
        invoke Module32Next, [snapshot], eax
        cmp eax, 1
        jne exit
        lea eax, [moduleEntry.szModule]
        cinvoke strcmp, <'client_panorama.dll', 0>, eax
        test eax, eax
        jnz loop3

    mov eax, [moduleEntry.modBaseAddr]
    ret
endp

section '.bss' data readable writable

clientId CLIENT_ID ?
objectAttributes OBJECT_ATTRIBUTES ?
processHandle dd ?
clientBase dd ?
localPlayer dd ?
crosshairID dd ?
forceAttack dd ?
team dd ?
entityList dd ?
entity dd ?
entityTeam dd ?
gameTypeCvar dd ?
gameTypeValue dd ?
glowObjectManager dd ?
glowIndex dd ?
glowEntity GLOW ?

section '.rdata' data readable

glowObjectManagerOffset dd 0x520DA80
glowIndexOffset dd 0xA3F8
localPlayerOffset dd 0xCBD6A4
entityListOffset dd 0x4CCDC3C
renderOccluded db 1
renderUnoccluded db 0
renderFullBloom db 0
sleepDuration dq -1

section '.idata' data readable import

library kernel32, 'kernel32.dll', \
        msvcrt, 'msvcrt.dll', \
        ntdll, 'ntdll.dll'

import kernel32, \
       CreateToolhelp32Snapshot, 'CreateToolhelp32Snapshot', \
       Module32First, 'Module32First', \
       Module32Next, 'Module32Next', \
       Process32First, 'Process32First', \
       Process32Next, 'Process32Next'

import msvcrt, \
       strcmp, 'strcmp', \
       printf, 'printf', \
       getchar, 'getchar'

import ntdll, \
       NtDelayExecution, 'NtDelayExecution', \
       NtOpenProcess, 'NtOpenProcess', \
       NtReadVirtualMemory, 'NtReadVirtualMemory', \
       NtTerminateProcess, 'NtTerminateProcess', \
       NtWriteVirtualMemory, 'NtWriteVirtualMemory'
