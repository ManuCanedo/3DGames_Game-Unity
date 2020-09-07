#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
#include <random>
#include <chrono>
#include <cctype>
#include <cstdlib>

using namespace std;

int main () 
{

// Setup
const int MAX_WRONG = 8;

vector<string> words;
words.push_back("VEJESTORIO");
words.push_back("MOMENTO");
words.push_back("SECUESTRO");
words.push_back("INDEPENDENCIA");
words.push_back("REPUBLICA");
words.push_back("TENISTA");
words.push_back("CEBOLLA");

unsigned seed = chrono::system_clock::now().time_since_epoch().count();
shuffle (words.begin(), words.end(), default_random_engine(seed));

const string THE_WORD = words[0];
int wrong = 0;
string soFar(THE_WORD.size(), '-');
string used ="";

cout << "Bienvenido al JUEGO DEL AHORCADO" << endl;

system ("PAUSE");

// Main Loop
while(wrong < MAX_WRONG && soFar != THE_WORD )
{

    cout << "\nTienes " << (MAX_WRONG - wrong) << " oportunidades de fallar restantes.\n";
    cout << "Has usado las siguientes letras: " << used << endl;
    cout << "La palabra a adivinar es la siguiente:\n";
    cout << "\n\t" << soFar << endl;

    char guess;
    
    cout << "\nIntroduce una nueva letra: ";
    cin >> guess;
    guess = toupper(guess);
    while (used.find(guess) != string::npos)
    {
        
        cout << "Ya has introducido la letra " << guess << endl;
        cout << "Introduce una nueva letra: ";
        cin >> guess;
        guess = toupper(guess);

    }

    used += guess;

    if (THE_WORD.find(guess) != string::npos)
    {

        cout << "\nEso es! La letra " << guess << " esta en la palabra!\n";

        for (int i = 0; i < THE_WORD.length(); i++)
        {
            if (THE_WORD[i] == guess)
            {
                soFar[i] = guess;
            }
        }

    }
    else
    {
        cout << "\nLastima! La letra " << guess << " no esta en la palabra\n";
        ++wrong;
    }


}

if (wrong == MAX_WRONG)
{
        cout << "Te han ahorcado :(\n";
        system ("PAUSE");
}
else
{
    cout << "Lo has adivinado!\n";
    system ("PAUSE");
}

cout << "\n La palabra era " << THE_WORD << endl;

return 0;

}
