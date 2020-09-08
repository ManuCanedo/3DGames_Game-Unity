#include <iostream>
#include <string>
#include <vector>
#include <chrono>
#include <random>
#include <ctime>
#include <algorithm>

using namespace std;

// CLASS DECLARATIONS
//////////
class Card
{
public:
    enum rank
    {
        ACE = 1,
        TWO,
        THREE,
        FOUR,
        FIVE,
        SIX,
        SEVE,
        EIGHT,
        NINE,
        TEN,
        JACK,
        QUEEN,
        KING
    };
    enum suit
    {
        CLUBS,
        DIAMONDS,
        HEARTS,
        SPADES
    };

    friend ostream &operator<<(ostream &os, const Card &aCard);

    Card(rank r = ACE, suit s = SPADES, bool ifu = true);

    int GetValue() const;
    void Flip();

private:
    rank m_Rank;
    suit m_Suit;
    bool m_IsFaceUp;
};

class Hand
{
public:
    Hand();
    virtual ~Hand();

    void Add(Card *pCard);
    void Clear();
    int GetTotal() const;

protected:
    vector<Card *> m_Cards;
};

class GenericPlayer : public Hand
{
    friend ostream &operator<<(ostream &os, const GenericPlayer &aGP);

public:
    GenericPlayer(const string &name = "");

    virtual ~GenericPlayer();

    virtual bool IsHitting() const = 0; // pure virtual
    bool IsBusted() const;
    void Bust() const;

protected:
    string m_Name;
};

class Player : public GenericPlayer
{
public:
    Player(const string &name = "");

    virtual ~Player();              // I use virtual keywords as reminders
    virtual bool IsHitting() const; // This functions have to be overriden

    void Win() const;
    void Lose() const;
    void Push() const;
};

class House : public GenericPlayer
{
public:
    House(const string &name = "House");
    virtual ~House();

    virtual bool IsHitting() const;
    void FlipFirstCard();
};

class Deck : public Hand
{
public:
    Deck();
    virtual ~Deck();

    void Populate();
    void Shuffle();
    void Deal(Hand &aHand);
    void AdditionalCards(GenericPlayer &aGenericPlayer);
};

class Game
{
public:
    Game(const vector<string> &names);

    ~Game();

    //plays the game of blackjack
    void Play();

private:
    Deck m_Deck;
    House m_House;
    vector<Player> m_Players;
};

// MEMBER DEFINITIONS
//////////
Card::Card(rank r, suit s, bool ifu) : m_Rank(r), m_Suit(s), m_IsFaceUp(ifu) {}

int Card::GetValue() const
{
    int value = 0;
    if (m_IsFaceUp)
        value = (value > 10) ? 10 : m_Rank;
    return value;
}

void Card::Flip()
{
    m_IsFaceUp = !(m_IsFaceUp);
}

Hand::Hand()
{
    m_Cards.reserve(7);
}

Hand::~Hand()
{
    Clear();
}

void Hand::Add(Card *pCard)
{
    m_Cards.push_back(pCard);
}

void Hand::Clear()
{
    vector<Card *>::iterator iter = m_Cards.begin();
    for (iter = m_Cards.begin(); iter != m_Cards.end(); iter++)
    {
        delete *iter;
        *iter = 0;
    }
    m_Cards.clear();
}

int Hand::GetTotal() const
{
    //if no cards in hand, return 0
    if (m_Cards.empty()) 
        return 0;

    //if a first card has value of 0, then card is face down; return 0
    if (m_Cards[0]->GetValue() == 0)
        return 0;

    //add up card values, treat each Ace as 1
    int total = 0;
    vector<Card *>::const_iterator iter;
    for (iter = m_Cards.begin(); iter != m_Cards.end(); ++iter)
        total += (*iter)->GetValue();

    //determine if hand contains an Ace
    bool containsAce = false;
    for (iter = m_Cards.begin(); iter != m_Cards.end(); ++iter)
        if ((*iter)->GetValue() == Card::ACE)
            containsAce = true;

    //if hand contains Ace and total is low enough, treat Ace as 11
    if (containsAce && total <= 11)
        //add only 10 since we've already added 1 for the Ace
        total += 10;
    
    return total;
}

GenericPlayer::GenericPlayer(const string &name) : m_Name(name) {}

GenericPlayer::~GenericPlayer() {}

bool GenericPlayer::IsBusted() const { return (GetTotal() > 21); }

void GenericPlayer::Bust() const
{
    cout << m_Name << " busts.\n";
}

Player::Player(const string &name) : GenericPlayer(name) {}

Player::~Player() {}

bool Player::IsHitting() const
{
    char response;
    cout << m_Name << ", do you want a hit? (Y/N): ";
    cin >> response;
    return (response == 'y' || response == 'Y');
}

void Player::Win() const
{
    cout << m_Name << " wins.\n";
}

void Player::Lose() const
{
    cout << m_Name << " loses.\n";
}

void Player::Push() const
{
    cout << m_Name << " pushes.\n";
}

House::House(const string &name) : GenericPlayer(name) {}

House::~House() {}

bool House::IsHitting() const { return (GetTotal() <= 16); }

void House::FlipFirstCard()
{
    if (!(m_Cards.empty()))
        m_Cards[0]->Flip();
    else
        cout << "No card to flip!\n";
}

Deck::Deck()
{
    m_Cards.reserve(52);
    Populate();
}

Deck::~Deck() {}

void Deck::Populate()
{
    Clear();
    for (int s = Card::CLUBS; s <= Card::SPADES; ++s)
        for (int r = Card::ACE; r <= Card::KING; ++r)
            Add(new Card(static_cast<Card::rank>(r), static_cast<Card::suit>(s)));
}

void Deck::Shuffle()
{
    // Refractoring Bookmark: check static
    static unsigned m_Seed = chrono::system_clock::now().time_since_epoch().count();
    shuffle(m_Cards.begin(), m_Cards.end(), default_random_engine(m_Seed));
}

void Deck::Deal(Hand &aHand)
{
    if (!(m_Cards.empty()))
    {
        aHand.Add(m_Cards.back());
        m_Cards.pop_back();
    }
    else
        cout << "Out of cards. Unable to deal.\n";
}

void Deck::AdditionalCards(GenericPlayer &aGenericPlayer)
{
    cout << endl;
    //continue to deal a card as long as generic player isn't busted and
    //wants another hit
    while (!(aGenericPlayer.IsBusted()) && aGenericPlayer.IsHitting())
    {
        Deal(aGenericPlayer);
        cout << aGenericPlayer << endl;

        if (aGenericPlayer.IsBusted())
            aGenericPlayer.Bust();
    }
}

Game::Game(const vector<string> &names)
{
    //create a vector of players from a vector of names
    vector<string>::const_iterator pName;
    for (pName = names.begin(); pName != names.end(); ++pName)
        m_Players.push_back(Player(*pName));

    //seed the random number generator
    srand(static_cast<unsigned int>(time(0)));
    m_Deck.Populate();
    m_Deck.Shuffle();
}

Game::~Game() {}

void Game::Play()
{
    //deal initial 2 cards to everyone
    vector<Player>::iterator pPlayer;
    for (int i = 0; i < 2; ++i)
    {
        for (pPlayer = m_Players.begin(); pPlayer != m_Players.end(); ++pPlayer)
            m_Deck.Deal(*pPlayer);
        m_Deck.Deal(m_House);
    }

    //hide house's first card
    m_House.FlipFirstCard();

    //display everyone's hand
    for (pPlayer = m_Players.begin(); pPlayer != m_Players.end(); ++pPlayer)
        cout << *pPlayer << endl;
    cout << m_House << endl;

    //deal additional cards to players
    for (pPlayer = m_Players.begin(); pPlayer != m_Players.end(); ++pPlayer)
        m_Deck.AdditionalCards(*pPlayer);

    //reveal house's first card
    m_House.FlipFirstCard();
    cout << endl
         << m_House;

    //deal additional cards to house
    m_Deck.AdditionalCards(m_House);

    if (m_House.IsBusted())
    {
        //everyone still playing wins
        for (pPlayer = m_Players.begin(); pPlayer != m_Players.end(); ++pPlayer)
            if (!(pPlayer->IsBusted()))
                pPlayer->Win();
    }
    else
    {
        //compare each player still playing to house
        for (pPlayer = m_Players.begin(); pPlayer != m_Players.end();
             ++pPlayer)
        {
            if (!(pPlayer->IsBusted()))
            {
                if (pPlayer->GetTotal() > m_House.GetTotal())
                    pPlayer->Win();
                else if (pPlayer->GetTotal() < m_House.GetTotal())
                    pPlayer->Lose();
                else
                    pPlayer->Push();
            }
        }
    }

    //remove everyone's cards
    for (pPlayer = m_Players.begin(); pPlayer != m_Players.end(); ++pPlayer)
        pPlayer->Clear();
    m_House.Clear();
}

// MAIN
//////////
ostream &operator<<(ostream &os, const Card &aCard);
ostream &operator<<(ostream &os, const GenericPlayer &aGenericPlayer);

int main()
{
    int numPlayers = 0;

    cout << "\t\tWelcome to Blackjack!\n\n";
    while (numPlayers < 1 || numPlayers > 7)
    {
        cout << "How many players? (1 - 7): ";
        cin >> numPlayers;
    }

    vector<string> names;
    string name;
    for (int i = 0; i < numPlayers; ++i)
    {
        cout << "Enter player name: ";
        cin >> name;
        names.push_back(name);
    }
    cout << endl;

    //the game loop
    Game aGame(names);
    char again = 'y';
    while (again != 'n' && again != 'N')
    {
        aGame.Play();
        cout << "\nDo you want to play again? (Y/N): ";
        cin >> again;
    }

    return 0;
}

//overloads << operator so Card object can be sent to cout
ostream &operator<<(ostream &os, const Card &aCard)
{
    const string RANKS[] = {"0", "A", "2", "3", "4", "5", "6", "7", "8", "9",
                            "10", "J", "Q", "K"};
    const string SUITS[] = {"c", "d", "h", "s"};

    if (aCard.m_IsFaceUp)
        os << RANKS[aCard.m_Rank] << SUITS[aCard.m_Suit];
    else
        os << "XX";

    return os;
}

//overloads << operator so a GenericPlayer object can be sent to cout
ostream &operator<<(ostream &os, const GenericPlayer &aGenericPlayer)
{
    os << aGenericPlayer.m_Name << ":\t";

    vector<Card *>::const_iterator pCard;
    if (!aGenericPlayer.m_Cards.empty())
    {
        for (pCard = aGenericPlayer.m_Cards.begin();
             pCard != aGenericPlayer.m_Cards.end();
             ++pCard)
            os << *(*pCard) << "\t";

        if (aGenericPlayer.GetTotal() != 0)
            cout << "(" << aGenericPlayer.GetTotal() << ")";
    }
    else
        os << "<empty>";

    return os;
}
