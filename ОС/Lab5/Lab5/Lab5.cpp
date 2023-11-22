#include <iostream>
#include <Windows.h>
#include <thread>

int main() {
    // Устанавливаем кодировку для ввода и вывода в русскую (Windows-1251)
    SetConsoleCP(1251);
    SetConsoleOutputCP(1251);

    // Идентификатор текущего процесса
    DWORD currentProcessId = GetCurrentProcessId();
    std::cout << "Идентификатор текущего процесса: " << currentProcessId << std::endl;

    // Идентификатор текущего (main) потока
    DWORD currentThreadId = GetCurrentThreadId();
    std::cout << "Идентификатор текущего (main) потока: " << currentThreadId << std::endl;

    // Приоритет (приоритетный класс) текущего процесса
    int currentProcessPriority = GetPriorityClass(GetCurrentProcess());
    std::cout << "Приоритет текущего процесса: " << currentProcessPriority << std::endl;

    // Приоритет текущего потока
    int currentThreadPriority = GetThreadPriority(GetCurrentThread());
    std::cout << "Приоритет текущего потока: " << currentThreadPriority << std::endl;
    SetProcessAffinityMask(GetCurrentProcess(), 3);
    // Маска доступных процессу процессоров в двоичном виде
    DWORD_PTR processAffinityMask, systemAffinityMask;
    if (GetProcessAffinityMask(GetCurrentProcess(), &processAffinityMask, &systemAffinityMask)) {
        std::cout << "Маска (affinity mask) доступных процессу процессоров в двоичном виде: " << processAffinityMask << std::endl;
    }

   
    int count = 0;
    while (processAffinityMask) {
        count += processAffinityMask & 1; 
        processAffinityMask >>= 1; 
    }
    // Количество процессоров доступных процессу
    int numberOfProcessors = count;
    std::cout << "Количество процессоров доступных процессу: " << numberOfProcessors << std::endl;

    // Процессор, назначенный текущему потоку
    int currentThreadProcessor = GetCurrentProcessorNumber();
    std::cout << "Процессор, назначенный текущему потоку: " << currentThreadProcessor << std::endl;

    return 0;
}