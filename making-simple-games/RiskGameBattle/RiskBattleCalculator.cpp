#include <iostream>
#include <cstdlib>
#include <ctime>
#include <algorithm>

using namespace std;

struct Battlefield {
	int attackersDied;
	int defendersDied;
};

int main()
{
	// Variables
	enum Mode { STANDARD = 1, CUSTOM, FULLCOMMIT, EXIT };
	int selection, attackers, defenders;
	Battlefield btf;
	bool continueLoop = true;
	char continueInput = 'y';

	// Function Declaration
	int printResult(Battlefield);
	Battlefield calculateFight(int, int, bool);

	// Start
	srand(static_cast<unsigned int>(time(0)));
	cout << "\nWelcome to RISK BATTLE CALCULATOR";

	// Main Game Loop
	bool exit = false;
	while (!exit) {
		cout << endl << flush;

		cout << "\nPlease select a MODE\n";
		cout << "\n1. STANDARD: Result of a single combat."
		     << "\n2. CUSTOM: Result of the entire battle."
		     << " The attacker may retreat after each skirmish"
		     << "\n3. FULL COMMIT: Result of the entire battle. Victory or death!"
		     << "\n4. EXIT\n\nMode selected: ";
		cin >> selection;

		switch (selection) {
		case STANDARD:
			btf = calculateFight(3, 2, false);
			printResult(btf);
			break;

		case CUSTOM:
			cout << "Please enter number of total attackers: ";
			cin >> attackers;
			cout << "Please enter number of total defenders: ";
			cin >> defenders;

			continueLoop = true;
			continueInput = 'y';

			while (continueLoop) {
				if (attackers >= 1 && defenders >= 1) {
					btf = calculateFight(attackers, defenders, false);
					attackers -= btf.attackersDied;
					defenders -= btf.defendersDied;

					cout << "\n\nA new skirmish begins!";
					printResult(btf);
					cout << "\n\nThere are " << attackers << " attackers and "
					     << defenders << " defenders remaining.";
					cout << "\nDo you want to continue? (y/n): ";
					cin >> continueInput;

					if (continueInput == 'y') {
						continueLoop = true;
					} else {
						continueLoop = false;
					}

				} else {
					if (attackers == 0) {
						cout << "\n\nThe attackers have been defeated and retreat to their territories!";
					} else if (defenders == 0) {
						cout << "\n\nThe defenders have been defeated the territory has been occupied!";
					} else {
						cout << "\n\nMETIESTE LA PATA MANOLITO\n\n";
					}
					continueLoop = false;
				}
			}
			break;

		case FULLCOMMIT:
			cout << "Please enter number of total attackers: ";
			cin >> attackers;
			cout << "Please enter number of total defenders: ";
			cin >> defenders;
			btf = calculateFight(attackers, defenders, true);
			printResult(btf);

			break;

		case EXIT:
			exit = true;
			break;

		default:
			cout << "\nPlease choose a valid MODE\n\n";
			break;
		}
		// End Switch
	}
	// End Game Loop
	return 0;
}

Battlefield calculateFight(int att, int def, bool commit)
{
	int attDied = 0, defDied = 0;

	// Function body
	do {
		int attDiceRoll[3] = { 0, 0, 0 }, defDiceRoll[2] = { 0, 0 };

		for (int i = 0; i < 3 && i < att; i++) {
			attDiceRoll[i] = rand() % 6 + 1;
		}
		for (int i = 0; i < 2 && i < def; i++) {
			defDiceRoll[i] = rand() % 6 + 1;
		}

		sort(attDiceRoll, attDiceRoll + 3);
		sort(defDiceRoll, defDiceRoll + 2);

		if (attDiceRoll[2] > defDiceRoll[1]) {
			defDied++;
			def--;
		} else {
			attDied++;
			att--;
		}
		if (attDiceRoll[1] > defDiceRoll[0] && defDiceRoll[0] != 0 && attDiceRoll != 0) {
			defDied++;
			def--;
		} else if (defDiceRoll[0] != 0 && attDiceRoll != 0) {
			attDied++;
			att--;
		} else {
			//Check
		}

	} while (att > 1 && def > 0 && commit);

	Battlefield result{ attDied, defDied };
	return result;
}

int printResult(Battlefield btf)
{
	if (btf.attackersDied) {
		if (btf.attackersDied == 1)
			cout << "\n1 attacker has died!";
		else {
			cout << "\n" << btf.attackersDied << " attackers have died!";
		}
	}
	if (btf.defendersDied) {
		if (btf.defendersDied == 1)
			cout << "\n1 defender has died!";
		else {
			cout << "\n" << btf.defendersDied << " defenders have died!";
		}
	}
	return 0;
}