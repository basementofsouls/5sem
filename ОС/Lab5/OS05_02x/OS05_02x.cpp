#include <iostream>
#include <Windows.h>

int main() {
    // Устанавливаем кодировку для ввода и вывода в русскую (Windows-1251)
    SetConsoleCP(1251);
    SetConsoleOutputCP(1251);

    // Вывод информации (номер итерации, идентификаторы и т.д.)
    DWORD processId = GetCurrentProcessId();
    DWORD threadId = GetCurrentThreadId();

    
    HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
    // Пример установки цвета текста
    SetConsoleTextAttribute(hConsole, FOREGROUND_GREEN);

    for (int iteration = 1; iteration <= 1000000; ++iteration) {
        if (iteration % 1000 == 0) {
            Sleep(200);
            std::cout << "Итерация: "               << iteration
                << " | ID процесса: "               << processId
                << " | ID потока: "                 << threadId
                << " | Приоритет процесса: "        << GetPriorityClass(GetCurrentProcess())
                << " | Приоритет потока: "          << GetThreadPriority(GetCurrentThread())
                << " | Назначенный процессор: "     << GetCurrentProcessorNumber() << std::endl;
        }
    }
    char a;
    std::cin >> a;
    return 0;
}