heroes = ["leto", "duncan", "goku"]
evenHeroes = [hero for hero, index in heroes from 1 til -1 while foo(hero, index) when (index % 2) == 0]