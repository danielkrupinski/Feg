format PE GUI 6.0
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

section '.text' code executable

start:
    stdcall findProcessId
    mov [processId], eax
    stdcall findModuleBase, eax
    mov [clientBase], eax
    invoke OpenProcess, PROCESS_VM_READ + PROCESS_VM_WRITE + PROCESS_VM_OPERATION, FALSE, [processId]
    mov [processHandle], eax

glow:
    lea eax, [sleepDuration]
    invoke NtDelayExecution, FALSE, eax
    lea eax, [localPlayer]
    mov ebx, [clientBase]
    add ebx, [localPlayerOffset]
    invoke NtReadVirtualMemory, dword [processHandle], ebx, eax, 4, NULL
    test eax, eax
    jnz exit
    mov eax, [localPlayer]
    test eax, eax
    jz glow
    mov eax, [clientBase]
    add eax, [glowObjectManagerOffset]
    lea ebx, [glowObjectManager]
    invoke NtReadVirtualMemory, dword [processHandle], eax, ebx, 4, NULL
    cmp [glowObjectManager], 0
    je glow
    mov eax, [clientBase]
    add eax, 0x3F0064
    lea ebx, [gameTypeCvar]
    invoke NtReadVirtualMemory, dword [processHandle], eax, ebx, 4, NULL
    mov eax, [gameTypeCvar]
    add eax, 48
    lea ebx, [gameTypeValue]
    invoke NtReadVirtualMemory, dword [processHandle], eax, ebx, 4, NULL
    mov eax, [gameTypeCvar]
    xor eax, [gameTypeValue]
    cmp eax, 6
    je render
    lea eax, [team]
    mov ebx, [localPlayer]
    add ebx, [teamOffset]
    invoke NtReadVirtualMemory, dword [processHandle], ebx, eax, 4, NULL
    jmp render1

render:
    xor eax, eax

loop1:
    inc eax
    push eax
    mov ecx, 0x10
    mul ecx
    add eax, [clientBase]
    add eax, [entityListOffset]
    lea ebx, [entity]
    invoke NtReadVirtualMemory, dword [processHandle], eax, ebx, 4, NULL

    mov eax, [entity]
    add eax, [glowIndexOffset]
    lea ebx, [glowIndex]
    invoke NtReadVirtualMemory, dword [processHandle], eax, ebx, 4, NULL

    mov eax, [glowIndex]
    mov ecx, 0x38
    mul ecx
    mov [glowEntity], eax
    add eax, [glowObjectManager]
    add eax, 0x4
    lea ebx, [red]
    invoke NtWriteVirtualMemory, dword [processHandle], eax, ebx, 4, NULL
    mov eax, [glowEntity]
    add eax, [glowObjectManager]
    add eax, 0x8
    lea ebx, [blue]
    invoke NtWriteVirtualMemory, dword [processHandle], eax, ebx, 4, NULL
    mov eax, [glowEntity]
    add eax, [glowObjectManager]
    add eax, 0xC
    lea ebx, [green]
    invoke NtWriteVirtualMemory, dword [processHandle], eax, ebx, 4, NULL
    mov eax, [glowEntity]
    add eax, [glowObjectManager]
    add eax, 0x24
    lea ebx, [renderOccluded]
    invoke NtWriteVirtualMemory, dword [processHandle], eax, ebx, 1, NULL
    mov eax, [glowEntity]
    add eax, [glowObjectManager]
    add eax, 0x25
    lea ebx, [renderUnoccluded]
    invoke NtWriteVirtualMemory, dword [processHandle], eax, ebx, 1, NULL
    mov eax, [glowEntity]
    add eax, [glowObjectManager]
    add eax, 0x26
    lea ebx, [renderFullBloom]
    invoke NtWriteVirtualMemory, dword [processHandle], eax, ebx, 1, NULL

    pop eax
    cmp eax, 64
    jle loop1
    jmp glow

render1:
    xor eax, eax

loop2:
    inc eax
    push eax
    mov ecx, 0x10
    mul ecx
    add eax, [clientBase]
    add eax, [entityListOffset]
    lea ebx, [entity]
    invoke NtReadVirtualMemory, dword [processHandle], eax, ebx, 4, NULL

    mov eax, [entity]
    add eax, [glowIndexOffset]
    lea ebx, [glowIndex]
    invoke NtReadVirtualMemory, dword [processHandle], eax, ebx, 4, NULL

    mov eax, [entity]
    add eax, [teamOffset]
    lea ebx, [entityTeam]
    invoke NtReadVirtualMemory, dword [processHandle], eax, ebx, 4, NULL
    mov eax, [entityTeam]
    cmp eax, [team]
    je loop2

    mov eax, [entity]
    add eax, [glowIndexOffset]
    lea ebx, [glowIndex]
    invoke NtReadVirtualMemory, dword [processHandle], eax, ebx, 4, NULL

    mov eax, [glowIndex]
    mov ecx, 0x38
    mul ecx
    mov [glowEntity], eax
    add eax, [glowObjectManager]
    add eax, 0x4
    lea ebx, [red]
    invoke NtWriteVirtualMemory, dword [processHandle], eax, ebx, 4, NULL
    mov eax, [glowEntity]
    add eax, [glowObjectManager]
    add eax, 0x8
    lea ebx, [blue]
    invoke NtWriteVirtualMemory, dword [processHandle], eax, ebx, 4, NULL
    mov eax, [glowEntity]
    add eax, [glowObjectManager]
    add eax, 0xC
    lea ebx, [green]
    invoke NtWriteVirtualMemory, dword [processHandle], eax, ebx, 4, NULL
    mov eax, [glowEntity]
    add eax, [glowObjectManager]
    add eax, 0x24
    lea ebx, [renderOccluded]
    invoke NtWriteVirtualMemory, dword [processHandle], eax, ebx, 1, NULL
    mov eax, [glowEntity]
    add eax, [glowObjectManager]
    add eax, 0x25
    lea ebx, [renderUnoccluded]
    invoke NtWriteVirtualMemory, dword [processHandle], eax, ebx, 1, NULL
    mov eax, [glowEntity]
    add eax, [glowObjectManager]
    add eax, 0x26
    lea ebx, [renderFullBloom]
    invoke NtWriteVirtualMemory, dword [processHandle], eax, ebx, 1, NULL
    
    pop eax
    cmp eax, 64
    jle loop1
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
    lea eax, [snapshot]
    lea ebx, [processEntry]
    invoke Process32First, dword [eax], ebx
    cmp eax, 1
    jne exit
    loop3:
        lea eax, [snapshot]
        lea ebx, [processEntry]
        invoke Process32Next, dword [eax], ebx
        cmp eax, 1
        jne exit
        lea eax, [processEntry.szExeFile]
        cinvoke strcmp, <'csgo.exe', 0>, eax
        test eax, eax
        jnz loop3

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
    lea eax, [snapshot]
    lea ebx, [moduleEntry]
    invoke Module32First, dword [eax], ebx
    cmp eax, 1
    jne exit
    loop4:
        lea eax, [snapshot]
        lea ebx, [moduleEntry]
        invoke Module32Next, dword [eax], ebx
        cmp eax, 1
        jne exit
        lea eax, [moduleEntry.szModule]
        cinvoke strcmp, <'client_panorama.dll', 0>, eax
        test eax, eax
        jnz loop4

    mov eax, [moduleEntry.modBaseAddr]
    ret
endp

section '.bss' data readable writable

processId dd ?
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
glowEntity dd ?

section '.rdata' data readable

glowObjectManagerOffset dd 0x520DA28
glowIndexOffset dd 0xA3F8
localPlayerOffset dd 0xCBD6B4
crosshairIdOffset dd 0xB390
forceAttackOffset dd 0x30FF2A0
teamOffset dd 0xF4
entityListOffset dd 0x4CCDBFC
red dd 0x437f0000
green dd 0x00000000
blue dd 0x00000000
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
       OpenProcess, 'OpenProcess', \
       Process32First, 'Process32First', \
       Process32Next, 'Process32Next'

import msvcrt, \
       strcmp, 'strcmp'

import ntdll, \
       NtDelayExecution, 'NtDelayExecution', \
       NtReadVirtualMemory, 'NtReadVirtualMemory', \
       NtTerminateProcess, 'NtTerminateProcess', \
       NtWriteVirtualMemory, 'NtWriteVirtualMemory'
