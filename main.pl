
% Game.
	main :- 
			build_KB, 
			play, 
			write('Note: to clear KB write ?- clear_KB.'), nl.
			
	%**************************************************************%
	
	
% Building KB phase.
build_KB:- 
			write('Welcome to Pro-Wordle!'), nl, 
			write('----------------------'), nl, nl, 
			words_and_categories, 
			write('Done building the words database...'), nl, nl.

words_and_categories:- 
					write('Please enter a word and its category on separate lines:'), nl, 
					read(Word), 
					(
						Word = done, 
						(
							word(_, _), nl;
							\+word(_, _), 
							write('You should enter at least one word and its category.'), nl, 
							words_and_categories
						);
						read(Category), 
						assert(word(Word, Category)), 
						words_and_categories
					).

	%**************************************************************%
	
% Playing phase.
	play :- 
			write('The available categories are: '), 
			categories(List), 
			write(List), nl, 
			choose_a_category(Category, List), 
			choose_a_length(Length, Category), 
			write('Game started. You have '), 
			N is Length + 1, 
			write(N), 
			write(' guesses.'), nl, nl, 
			pick_random_word(Word, Length, Category), 
			guess(Word, N, Length).
			
	%**************************************************************%
	
% Clear KB.
	clear_KB :- 
			word(_, _), 
			retractall(word(_, _)), 	
			write('Done! KB is empty.'), ! ;
			write('KB is already empty!'), 
			retract(word(_, _)).
			
	%**************************************************************%
	
% Helper methods.

:- dynamic(word/2).

choose_a_category(C, L) :- 
					write('choose a category:'), nl, 
					read(X), 
					(
						member(X, L), 
						C = X, nl;
						write('This category does not exist.'), nl, 
						choose_a_category(C, L)
					).
					
choose_a_length(L, C) :- 
					write('Choose a length:'), nl, 
					read(X), 
					(
						pick_word(_, X, C), 
						L = X, nl;
						write('There are no words of this length.'), nl, 
						choose_a_length(L, C)
					).
guess(_, 0, _) :- write('You lost!'), nl.	
guess(W, N, L) :- 
				write('Enter a word composed of '), 
				write(L), 
				write(' letters:'), nl, 
				read(A), 
				(
					A = W, nl, 
					write('You Won!'), nl;
	
					string_length(A, B), 
					B \= L, 
					write('Word is not composed of '), 
					write(L), 
					write('  letters. Try again.'), nl, 
					write('Remaining Guesses are '), 
					write(N), nl, nl, 
					guess(W, N, L);
					
					N1 is N - 1, 
					string_chars(A, L1), 
					string_chars(W, L2), 
					correct_letters(L1, L2, CL), 
					correct_positions(L1, L2, CP), 
					write('Correct letters are: '), 
					write(CL), nl, 
					write('Correct letters in correct positions are '), 
					write(CP), nl, 
					(	
						N1 \= 0, 
						write('Remaining Guesses are '), 
						write(N1), nl, nl, 
						guess(W, N1, L);
						guess(W, N1, L)
					)
				).
				
				

is_category(C) :- word(_, C).

categories(L) :- setof(C, is_category(C), L).

available_length(L) :- 
					word(X, _), 
					string_length(X, L).
					
pick_word(W, L, C) :-
					word(W, C), 
					string_length(W, L).
					
pick_random_word(W, L, C) :- 
						setof(W, pick_word(W, L, C), R), 
						random_member(W, R).

correct_letters([], _, []).
correct_letters([H|T], L2, CL) :- 
					member(H, L2), 
					CL = [H|TL], 
					correct_letters(T, L2, TL).
correct_letters([H|T], L2, CL) :- 
					\+member(H, L2), 
					correct_letters(T, L2, CL).

correct_positions([], [], []).					
correct_positions([H|T1], [H|T2], [H|T]) :- correct_positions(T1, T2, T).
correct_positions([_|T1], [_|T2], PL) :- correct_positions(T1, T2, PL).
