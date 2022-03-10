:-use_module(library(clpfd)).
:-use_module(library(lists)).
:-use_module(library(random)).
	  
processRows([], _Board, _Row-_Col, _Size).

processRows([H|T], Board, Row-Col, Size):-
	processRow(H, Board, Row-Col, Size, []),
	NewRow is Row + 1,
	processRows(T, Board, NewRow-0, Size).

processRow([], _Board, _Row-_Col, _Size, _VarList).

processRow([H|T], Board, Row-Col, Size, _VarList):-
	H == 15,
	NewCol is Col + 1,
	processRow(T, Board, Row-NewCol, Size, []).
					
processRow([H|T], Board, Row-Col, Size, _VarList):-
	compare(H),
	hintRestriction(Board, Row-Col, H, Size),
	NewCol is Col + 1,
	processRow(T, Board, Row-NewCol, Size, []).
											
processRow([H|T], Board, Row-Col, Size, VarList):-
	insertAtEnd(H, [], L),
	sum(L, #=<, 1), % each space can have at most one light
	gatherLeft(Board, Row-Col, Row-Col, Size, VarList),
	NewCol is Col + 1,
	processRow(T, Board, Row-NewCol, Size, []).

hintRestriction(Board, Row-Col, NumberHigh, Size):-
	Number is NumberHigh - 10,			
	NewRow1 is Row - 1,
	getUpSquare(Board, NewRow1-Col, Size, US),
	append(US, [], List),
	NewRow2 is Row + 1,
	getDownSquare(Board, NewRow2-Col, Size, DS),
	append(DS, List, List2),
	NewCol1 is Col - 1,
	getLeftSquare(Board, Row-NewCol1, Size, LS),
	append(LS, List2, List3),
	NewCol2 is Col + 1,
	getRightSquare(Board, Row-NewCol2, Size, RS),
	append(RS, List3, FinalList),
	sum(FinalList, #=, Number).
								
getUpSquare(_Board, Row-_Col, _Size, US):-
	Row < 0, 
	US = [].
										
getUpSquare(Board, Row-Col, _Size, US):-
	getElem(Board, Row-Col, Elem),
	compare(Elem),
	US = [].		
										
getUpSquare(Board, Row-Col, _Size, US):-
	getElem(Board, Row-Col, Elem),
	US = [Elem].
										
getDownSquare(_Board, Row-_Col, Size, DS):-
	Row >= Size,
	DS = [].

getDownSquare(Board, Row-Col, _Size, DS):-
	getElem(Board, Row-Col, Elem),
	compare(Elem),
	DS = [].
										
getDownSquare(Board, Row-Col, _Size, DS):-
	getElem(Board, Row-Col, Elem),
	DS = [Elem].
										
getLeftSquare(_Board, _Row-Col, _Size, LS):-
	Col < 0,
	LS = [].

getLeftSquare(Board, Row-Col, _Size, LS):-
	getElem(Board, Row-Col, Elem),
	compare(Elem),
	LS = [].
										
getLeftSquare(Board, Row-Col, _Size, LS):-
	getElem(Board, Row-Col, Elem),
	LS = [Elem].

getRightSquare(_Board, _Row-Col, Size, RS):-
	Col >= Size,
	RS = [].

getRightSquare(Board, Row-Col, _Size, RS):-
	getElem(Board, Row-Col, Elem),
	compare(Elem),
	RS = [].
										
getRightSquare(Board, Row-Col, _Size, RS):-
	getElem(Board, Row-Col, Elem),
	RS = [Elem].
			
gatherLeft(Board, ORow-OCol, _CRow-CCol, Size, RowList):-
	CCol < 0,
	NewCol is OCol + 1,
	gatherRight(Board, ORow-OCol, ORow-NewCol, Size, RowList).
													
gatherLeft(Board, ORow-OCol, CRow-CCol, Size, RowList):-
	getElem(Board, CRow-CCol, Elem),
	compare(Elem),
	NewCol is OCol + 1,
	gatherRight(Board, ORow-OCol, ORow-NewCol, Size, RowList).
																				
gatherLeft(Board, ORow-OCol, CRow-CCol, Size, RowList):-
	getElem(Board, CRow-CCol, Elem),
	insertAtEnd(Elem, RowList, NewRowList),
	NewCol is CCol - 1,
	gatherLeft(Board, ORow-OCol, CRow-NewCol, Size, NewRowList).
				
gatherRight(Board, ORow-OCol, _CRow-CCol, Size, RowList):-
	CCol >= Size,
	sum(RowList, #=<, 1),
	gatherUp(Board, ORow-OCol, ORow-OCol, Size, RowList, []).
													
gatherRight(Board, ORow-OCol, CRow-CCol, Size, RowList):-
	getElem(Board, CRow-CCol, Elem),
	compare(Elem),
	sum(RowList, #=<, 1),
	gatherUp(Board, ORow-OCol, ORow-OCol, Size, RowList, []).
													
gatherRight(Board, ORow-OCol, CRow-CCol, Size, RowList):-
	getElem(Board, CRow-CCol, Elem),
	insertAtEnd(Elem, RowList, NewRowList),
	NewCol is CCol + 1,
	gatherRight(Board, ORow-OCol, CRow-NewCol, Size, NewRowList).
										
gatherUp(Board, ORow-OCol, CRow-_CCol, Size, VarList, ColList):-
	CRow < 0,
	NewRow is ORow + 1,
	gatherDown(Board, ORow-OCol, NewRow-OCol, Size, VarList, ColList).
													
gatherUp(Board, ORow-OCol, CRow-CCol, Size, VarList, ColList):-
	getElem(Board, CRow-CCol, Elem),
	compare(Elem),
	NewRow is ORow + 1,
	gatherDown(Board, ORow-OCol, NewRow-OCol, Size, VarList, ColList).
													
gatherUp(Board, ORow-OCol, CRow-CCol, Size, VarList, ColList):-
	getElem(Board, CRow-CCol, Elem),
	insertAtEnd(Elem, VarList, NewVarList),
	insertAtEnd(Elem, ColList, NewColList),
	NewRow is CRow - 1,
	gatherUp(Board, ORow-OCol, NewRow-CCol, Size, NewVarList, NewColList).
												
gatherDown(_Board, _ORow-_OCol, CRow-_CCol, Size, VarList, ColList):-
	CRow >= Size,
	sum(ColList, #=<, 1),
	sum(VarList, #>=, 1).
													
gatherDown(Board, _ORow-_OCol, CRow-CCol, _Size, VarList, ColList):-
	getElem(Board, CRow-CCol, Elem),
	compare(Elem),
	sum(ColList, #=<, 1),
	sum(VarList, #>=, 1).
																																
gatherDown(Board, ORow-OCol, CRow-CCol, Size, VarList, ColList):-
	getElem(Board, CRow-CCol, Elem),
	insertAtEnd(Elem, VarList, NewVarList),
	insertAtEnd(Elem, ColList, NewColList),
	NewRow is CRow + 1,
	gatherDown(Board, ORow-OCol, NewRow-CCol, Size, NewVarList, NewColList).
			
printLine(0).
printLine(Count):-
	write(' ---'),
	Count2 is Count-1,
	printLine(Count2).

printElem(Piece) :- Piece=0, write('   ').
printElem(Piece) :- Piece=1, write(' * ').	
printElem(Piece) :- Piece=15, write(' # ').
printElem(Piece) :- Piece=10, write(' 0 ').
printElem(Piece) :- Piece=11, write(' 1 ').
printElem(Piece) :- Piece=12, write(' 2 ').
printElem(Piece) :- Piece=13, write(' 3 ').
printElem(Piece) :- Piece=14, write(' 4 ').				
						
printBoard(Board, Size) :- nl, printLine(Size), nl,	printList(Board, Size, Size).						

printList([],Size,_) :-
	write('|'), nl,
	printLine(Size), nl.

printList([H|T],Size, 0) :-
	write('|'), nl,
	printLine(Size), nl,
	printList([H|T],Size,Size).
					
printList([H|T], Size, Count) :-
	NewCount is Count - 1,
	write('|'),
	printElem(H),
	printList(T, Size, NewCount).	

%Support
length_list(L, Ls) :- length(Ls, L).

insertAtEnd(X,[ ],[X]).
insertAtEnd(X,[H|T],[H|Z]) :- insertAtEnd(X,T,Z). 

getElem(Board, Row-Col, Piece):-
	nth0(Row, Board, ColList),
	nth0(Col, ColList, Piece).

compare(Elem) :- Elem == 15.
compare(Elem) :- Elem == 10.
compare(Elem) :- Elem == 11.
compare(Elem) :- Elem == 12.
compare(Elem) :- Elem == 13.
compare(Elem) :- Elem == 14.

domain(List, Min, Max):-
  List ins Min..Max.

%MAIN

%Clear SWI Prolog cho lẹ
cls :- write('\e[H\e[2J').

lightup(Rows, Size) :-
	length(Rows, Size),
	maplist(length_list(Size), Rows),
	append(Rows, Board),
	domain(Board, 0, 15),
	processRows(Rows, Rows, 0-0, Size),
	labeling([], Board),
	printBoard(Board, Size).	


%
%Bảng quy đổi:
% _ = Empty space -> Space
% 1 = Đèn        --> *
%15 = Ô đen  	 --> #
%14 = Khối 4   	 --> 4
%13 = Khối 3     --> 3
%12 = Khối 2 	 --> 2
%11 = Khối 1 	 --> 1
%10 = Khối 0 	 --> 0
%

% OUTPUT MẪU:
%  --- --- --- --- --- --- ---
% |   | * |   | 0 |   | * |   |
%  --- --- --- --- --- --- ---
% | * | 3 | * |   |   | # |   |
%  --- --- --- --- --- --- ---
% |   |   | # | * | # |   | * |
%  --- --- --- --- --- --- ---
% | # | * |   | # |   | * | 3 |
%  --- --- --- --- --- --- ---
% | * |   | 2 | * | # |   | * |
%  --- --- --- --- --- --- ---
% |   | 2 | * |   |   | # |   |
%  --- --- --- --- --- --- ---
% |   | * |   | 1 | * |   |   |
%  --- --- --- --- --- --- ---

startdemo:-
		lightup([
		[_,_,15,_,12,_,_],
		[_,_,_,_,_,_,_],
		[12,_,_,_,_,_,10],
		[_,_,_,_,_,_,_],
		[10,_,_,_,_,_,15],
		[_,_,_,_,_,_,_],
		[_,_,15,_,11,_,_]],7).

start:-
		lightup([
		[_,_,_,10,_,_,_],
		[_,13,_,_,_,15,_],
		[_,_,15,_,15,_,_],
		[15,_,_,15,_,_,13],
		[_,_,12,_,15,_,_],
		[_,12,_,_,_,15,_],
		[_,_,_,11,_,_,_]],7).

start2:-
		lightup([
		[_,_,_,_,_,_,_],
		[_,_,_,12,_,_,_],
		[_,_,_,15,_,_,_],
		[_,11,13,_,15,12,_],
		[_,_,_,13,_,_,_],
		[_,_,_,11,_,_,_],
		[_,_,_,_,_,_,_]],7).

start3:-
		lightup([
		[_,_,_,_,_,_,_],
		[_,_,_,_,_,_,_],
		[_,_,_,_,_,_,_],
		[_,_,_,_,_,_,_],
		[_,_,_,_,_,_,_],
		[_,_,_,_,_,_,_],
		[_,_,_,_,_,_,_]],7).

start4:-
		lightup([
		[10,_,_,11,_,_,12],
		[_,_,_,_,_,_,_],
		[_,_,_,_,_,_,_],
		[13,_,_,_,_,_,10],
		[_,_,_,_,_,_,_],
		[_,_,_,_,_,_,_],
		[10,_,_,10,_,_,11]],7).

start5:-
		lightup([
		[_,_,_,11,_,_,_],
		[_,_,_,_,_,_,_],
		[_,_,_,13,_,_,_],
		[10,_,11,_,14,_,15],
		[_,_,_,15,_,_,_],
		[_,_,_,_,_,_,_],
		[_,_,_,10,_,_,_]],7).

start14:-
		lightup([
		[11,_,10,_,_,_,_,_,15,_,12,_,_,15],
		[_,_,_,_,15,_,_,_,15,15,_,_,_,_],
		[_,_,_,_,_,10,_,11,15,_,_,_,_,10],
		[15,_,_,_,_,_,_,_,_,15,_,_,_,_],
		[_,15,_,14,_,_,_,15,_,_,_,_,11,_],
		[15,15,15,_,_,_,_,_,_,_,_,11,_,_],
		[_,_,15,_,15,_,_,_,_,_,_,_,_,_],
		[_,_,_,_,_,_,_,_,_,11,_,10,_,_],
		[_,_,15,_,_,_,_,_,_,_,_,15,15,11],
		[_,13,_,_,_,_,15,_,_,_,13,_,15,_],
		[_,_,_,_,15,_,_,_,_,_,_,_,_,15],
		[15,_,_,_,_,15,10,_,10,_,_,_,_,_],
		[_,_,_,_,15,15,_,_,_,12,_,_,_,_],
		[12,_,_,15,_,15,_,_,_,_,_,11,_,15]
		],14).
