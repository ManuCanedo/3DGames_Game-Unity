#include <iostream>
#include <string>
#include <vector>
#include <algorithm>

using namespace std;

// global constants
const char X = 'X';
const char O = 'O';
const char EMPTY = ' ';
const char TIE = 'T';
const char NO_ONE = 'N';
const char HUMAN = 'H';
const char COMPUTER = 'C';

// function prototypes
void printStartScreen();
char askYesNo(string message);
void displayBoard(const vector<char>& rBoard);
int getHumanMove(const vector<char>& rBoard);
bool checkMove(const vector<char>& rBoard, int move);
int getComputerMove(vector<char> board); //board passed as value to test moves
char checkWin(const vector<char>& rBoard);
void printResult(char winner);

// main
int main()
{
	int move;
	const int NUM_SQUARES = 9;
	char turn;
	char winner = NO_ONE;

	// Start
	vector<char> board(NUM_SQUARES, EMPTY);
	printStartScreen();
	if (askYesNo("Do you require first move?") == 'Y') {
		turn = HUMAN;
	} else {
		turn = COMPUTER;
	}

	// Main Loop
	while (winner == NO_ONE) {
		displayBoard(board);

		if (turn == HUMAN) {
			move = getHumanMove(board);
			board[move] = X;
			turn = COMPUTER;

		} else {
			move = getComputerMove(board);
			board[move] = O;
			turn = HUMAN;
		}

		winner = checkWin(board);
	}

	// Ending Game
	printResult(winner);
	return 0;
}

// functions
void printStartScreen()
{
	cout << "Welcome to the ultimate man-machine showdown: Tic-Tac-Toe.\n";
	cout << "--where human brain is pit against silicon processor\n\n";

	cout << "Make your move known by entering a number, 0 - 8.  The number\n";
	cout << "corresponds to the desired board position, as illustrated:\n\n";

	cout << "       0 | 1 | 2\n";
	cout << "       ---------\n";
	cout << "       3 | 4 | 5\n";
	cout << "       ---------\n";
	cout << "       6 | 7 | 8\n\n";

	cout << "You will be using X.  I will be using O.\n";
	cout << "Prepare yourself, human.  The battle is about to begin.\n\n";
}

char askYesNo(string question)
{
	char response;
	do {
		cout << question << " (y/n): ";
		cin >> response;
		response = toupper(response);
	} while (response != 'Y' && response != 'N');

	return response;
}

void displayBoard(const vector<char>& board)
{
	cout << "\n\t" << board[0] << " | " << board[1] << " | " << board[2];
	cout << "\n\t"
	     << "---------";
	cout << "\n\t" << board[3] << " | " << board[4] << " | " << board[5];
	cout << "\n\t"
	     << "---------";
	cout << "\n\t" << board[6] << " | " << board[7] << " | " << board[8];
	cout << "\n\n";
}

int getHumanMove(const vector<char>& board)
{
	int move;
	do {
		int input;
		cout << "What's your next move? (Valid 0-8 square): ";
		cin >> move;

	} while (!checkMove(board, move));

	cout << "Fine...\n";
	return move;
}

bool checkMove(const vector<char>& board, int move)
{
	return (move >= 0 && move < 9 && board[move] == EMPTY);
}

int getComputerMove(vector<char> board)
{
	unsigned int move = 0;
	bool found = false;

	// if computer can win on next move, that's the move to make
	while (!found && move < board.size()) {
		if (checkMove(board, move)) {
			//try move
			board[move] = O;
			//test for winner
			found = checkWin(board) == COMPUTER;
			//undo move
			board[move] = EMPTY;
		}

		if (!found) {
			++move;
		}
	}

	// otherwise, if opponent can win on next move, that's the move to make
	if (!found) {
		move = 0;

		while (!found && move < board.size()) {
			if (checkMove(board, move)) {
				//try move
				board[move] = X;
				//test for winner
				found = checkWin(board) == HUMAN;
				//undo move
				board[move] = EMPTY;
			}

			if (!found) {
				++move;
			}
		}
	}

	// otherwise, moving to the best open square is the move to make
	if (!found) {
		move = 0;
		unsigned int i = 0;

		const int BEST_MOVES[] = { 4, 0, 2, 6, 8, 1, 3, 5, 7 };
		//pick best open square
		while (!found && i < board.size()) {
			move = BEST_MOVES[i];
			if (checkMove(board, move)) {
				found = true;
			}

			++i;
		}
	}

	cout << "I shall take square number " << move << endl;
	return move;
}

char checkWin(const vector<char>& board)
{
	// all possible winning rows
	const int WINNING_ROWS[8][3] = { { 0, 1, 2 }, { 3, 4, 5 }, { 6, 7, 8 }, { 0, 3, 6 },
					 { 1, 4, 7 }, { 2, 5, 8 }, { 0, 4, 8 }, { 2, 4, 6 } };
	const int TOTAL_ROWS = 8;

	// if any winning row has three values that are the same (and not EMPTY),
	// then we have a winner
	for (int row = 0; row < TOTAL_ROWS; ++row) {
		if ((board[WINNING_ROWS[row][0]] != EMPTY) &&
		    (board[WINNING_ROWS[row][0]] == board[WINNING_ROWS[row][1]]) &&
		    (board[WINNING_ROWS[row][1]] == board[WINNING_ROWS[row][2]])) {
			if (board[WINNING_ROWS[row][0]] == X) {
				return HUMAN;
			} else {
				return COMPUTER;
			}
		}
	}

	// since nobody has won, check for a tie (no empty squares left)
	if (count(board.begin(), board.end(), EMPTY) == 0)
		return TIE;

	// since nobody has won and it isn't a tie, the game ain't over
	return NO_ONE;
}

void printResult(char winner)
{
	if (winner == COMPUTER) {
		cout << winner << "'s won!\n";
		cout << "As I predicted, human, I am triumphant once more -- proof\n";
		cout << "that computers are superior to humans in all regards.\n";
	}

	else if (winner == HUMAN) {
		cout << winner << "'s won!\n";
		cout << "No, no!  It cannot be!  Somehow you tricked me, human.\n";
		cout << "But never again!  I, the computer, so swear it!\n";
	}

	else {
		cout << "It's a tie.\n";
		cout << "You were most lucky, human, and somehow managed to tie me.\n";
		cout << "Celebrate... for this is the best you will ever achieve.\n";
	}
}