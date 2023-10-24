#include <iostream>
#include <Windows.h>

int main() {
    setlocale(LC_ALL, "ru_RU.CP1251");
    SetConsoleCP(1251);
    SetConsoleOutputCP(1251);
    while (true) {

        // Получаем идентификатор текущего процесса
        DWORD processId = GetCurrentProcessId();

        // Выводим идентификатор процесса на консоль
        std::cout << "Идентификатор процесса: " << processId << std::endl;

        // Приостанавливаем выполнение программы на 2 секунды
        Sleep(2000); // Задержка в 2 секунды
    }

    return 0;
}