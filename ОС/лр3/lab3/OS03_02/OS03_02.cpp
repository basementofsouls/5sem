#include <iostream>
#include <Windows.h>
using namespace std;


int main() {
    setlocale(LC_ALL, "ru_RU.CP1251");
    SetConsoleCP(1251);
    SetConsoleOutputCP(1251);
   

    // Запускаем процесс OS03_02_1 как дочерний процесс
    STARTUPINFO si1 = {};
    PROCESS_INFORMATION pi1 = {};

    


    if (CreateProcess(
        L"E:\\5сем\\ОС\\лр3\\OS03_02_1.exe",   // Имя исполняемого файла OS03_02_1
        NULL,              // Аргументы командной строки (нет)
        NULL,              // Дескриптор безопасности процесса (по умолчанию)
        NULL,              // Дескриптор безопасности потока (по умолчанию)
        FALSE,             // Наследовать дескрипторы (нет)
        0,                 // Флаги создания (по умолчанию)
        NULL,              // Наследуемая среда (по умолчанию)
        NULL,              // Текущий каталог (по умолчанию)
        &si1,              // Информация о старте
        &pi1              // Информация о процессе
    )) {
        cout << " \n- Process OS03_02_1 created\n" << endl;
    }
    STARTUPINFO si2 = {};
    PROCESS_INFORMATION pi2 = {};
    // Запускаем процесс OS03_02_2 как дочерний процесс
    ZeroMemory(&si1, sizeof(STARTUPINFO)); si1.cb = sizeof(STARTUPINFO);
    ZeroMemory(&si2, sizeof(STARTUPINFO)); si2.cb = sizeof(STARTUPINFO);

    if (CreateProcess(
        L"E:\\5сем\\ОС\\лр3\\OS03_02_2.exe",   // Имя исполняемого файла OS03_02_2
        NULL,              // Аргументы командной строки (нет)
        NULL,              // Дескриптор безопасности процесса (по умолчанию)
        NULL,              // Дескриптор безопасности потока (по умолчанию)
        FALSE,             // Наследовать дескрипторы (нет)
        0,                 // Флаги создания (по умолчанию)
        NULL,              // Наследуемая среда (по умолчанию)
        NULL,              // Текущий каталог (по умолчанию)
        &si2,              // Информация о старте
        &pi2              // Информация о процессе
    )) {
        cout << " \n- Process OS03_02_2 created\n" << endl;
    }
    // Получаем и выводим идентификатор текущего процесса OS03_02
    CloseHandle(pi1.hProcess);
    CloseHandle(pi1.hThread);
    CloseHandle(pi2.hProcess);
    CloseHandle(pi2.hThread);
    return 0;
}
