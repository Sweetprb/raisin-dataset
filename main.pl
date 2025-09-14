%--------------------------------------------------------------------
% This Is An Interactive Prolog System To Classify
% RAISINS------- Into two classes namely 1) KECIMEN 2) BENSI
% -------------------------------------------------------------------

%-------inbuilt module for dealing with csv files----------
:- use_module(library(csv)).

% ---------------- Loading data from Raisin.csv file ----------------
load_data(Rows) :-
    csv_read_file('raisin1.csv', Raw, [functor(row)]),
    exclude(is_header, Raw, CleanRows),          % removing header row since its not needed for classification
    maplist(row_to_raisin, CleanRows, Rows).

% Identify the header row (so it won’t be classified)
is_header(row('Area', 'MajorAxisLength', 'MinorAxisLength',
              'Eccentricity', 'ConvexArea', 'Extent', 'Perimeter', 'Class')).

% Convert row(...) -> raisin(...) (since prolog words on facts)
% CSV order: Area, MajorAxisLength, MinorAxisLength, Eccentricity, ConvexArea, Extent, Perimeter, Class
% Raisin order: Class, Area, Perimeter, MajorAxisLength, MinorAxisLength, Eccentricity, ConvexArea, Extent
row_to_raisin(Row, raisin(Class, Area, Perimeter, MajorAxisLength,
                          MinorAxisLength, Eccentricity, ConvexArea, Extent)) :-
    Row =.. [row, Area, MajorAxisLength, MinorAxisLength,
             Eccentricity, ConvexArea, Extent, Perimeter, Class].

% raisin(Class, Area, Perimeter, MajorAxisLength, MinorAxisLength, Eccentricity, ConvexArea, Extent).


% ---------------- Decision Rules ----------------
% Rule : If MajorAxisLength <= 422.279133 AND Perimeter <= 1006.375 =>
% KECIMEN
predict(kecimen, _, Perimeter, MajorAxisLength, _, _, _, _) :-
    MajorAxisLength =< 422.279133,
    Perimeter =< 1006.375.

% Rule : If MajorAxisLength <= 422.279133 AND Perimeter >1006.375 AND
%  Area <= 62835 AND Extent <= 0.701678 AND Perimeter <= 1122.831 AND
%  Extent <= 0.671309 => BESNI
predict(besni, Area, Perimeter, MajorAxisLength, _, _, _, Extent) :-
    MajorAxisLength =< 422.279133,
    Perimeter > 1006.375,
    Extent =< 0.7476,
    Perimeter =< 1122.831,
    Area =< 62835,
    Extent =< 0.701678,
    Extent =< 0.666255.

% Rule : If MajorAxisLength <= 422.279133 AND Perimeter >1006.375 AND
%  Area <= 62835 AND Extent <= 0.701678 AND Perimeter <= 1122.831 AND
%  Extent > 0.671309 => KECIMEN
predict(kecimen, Area, Perimeter, MajorAxisLength, _, _, _, Extent) :-
    MajorAxisLength =< 422.279133,
    Perimeter > 1006.375,
    Extent =< 0.7476,
    Perimeter =< 1122.831,
    Area =< 62835,
    Extent =< 0.701678,
    Extent > 0.666255.

% Rule : If MajorAxisLength <= 422.279133 AND Perimeter >1006.375 AND
%  AND Extent <= 0.7476 AND Perimeter <= 1122.831 AND Extent > 0.701678
%  AND AREA <= 62835 => BESNI
predict(besni, Area, Perimeter, MajorAxisLength, _, _, _, Extent) :-
    MajorAxisLength =< 422.279133,
    Perimeter > 1006.375,
    Extent =< 0.7476,
    Perimeter =< 1122.831,
    Area =< 62835,
    Extent > 0.701678.

% Rule : If MajorAxisLength <= 422.279133 AND Perimeter >1006.375 AND
%  AND Extent <= 0.7476 AND Perimeter <= 1122.831 AND Extent <= 0.671309
%  AND AREA > 62835 => KECIMEN
predict(kecimen, Area, Perimeter, MajorAxisLength, _, _, _, Extent) :-
    MajorAxisLength =< 422.279133,
    Perimeter > 1006.375,
    Extent =< 0.7476,
    Perimeter =< 1122.831,
    Area > 62835.


% Rule : If MajorAxisLength <= 422.279133 AND Perimeter >1006.375 AND
%  AND Extent <= 0.7476 AND Perimeter > 1122.831 AND Extent <= 0.671309
% => BESNI
predict(besni, _, Perimeter, MajorAxisLength, _, _, _, Extent) :-
    MajorAxisLength =< 422.279133,
    Perimeter > 1006.375,
    Extent =< 0.7476,
    Perimeter > 1122.831,
    Extent =< 0.671309.


% Rule : If MajorAxisLength <= 422.279133 AND Perimeter >1006.375 AND
%  AND Extent <= 0.7476 AND Perimeter > 1122.831 AND Extent > 0.671309
%  AND Eccentricity <= 0.75951 => BESNI
predict(besni, _, Perimeter, MajorAxisLength, _, Eccentricity, _, Extent) :-
    MajorAxisLength =< 422.279133,
    Perimeter > 1006.375,
    Extent =< 0.7476,
    Perimeter > 1122.831,
    Extent > 0.671309,
    Eccentricity =< 0.75951.


% Rule : If MajorAxisLength <= 422.279133 AND Perimeter >1006.375 AND
%  AND Extent <= 0.7476 AND Perimeter > 1122.831 AND Extent > 0.671309
%  AND Eccentricity > 0.75951 => KECIMEN
predict(kecimen, _, Perimeter, MajorAxisLength, _, Eccentricity, _, Extent) :-
    MajorAxisLength =< 422.279133,
    Perimeter > 1006.375,
    Extent =< 0.7476,
    Perimeter > 1122.831,
    Extent > 0.671309,
    Eccentricity > 0.75951.

% Rule : If MajorAxisLength <= 422.279133 AND Perimeter >1006.375 AND
% Extent > 0.7476 => KECIMEN
predict(kecimen, _, Perimeter, MajorAxisLength, _, _, _, Extent) :-
    MajorAxisLength =< 422.279133,
    Perimeter > 1006.375,
    Extent > 0.7476.

% Rule : If MajorAxisLength > 422.279133 => BESNI
predict(besni, _, _, MajorAxisLength, _, _, _, _) :-
    MajorAxisLength > 422.279133.


% Classification of samples in the dataset
% ---------------------------------------------------------------------
classify_allsamples :-
    load_data(Rows),
    length(Rows, N),
    format("Loaded ~w samples.~n", [N]),
    forall(
        member(raisin(Actual, Area, Perimeter, MajorAxisLength,
                      MinorAxisLength, Eccentricity, ConvexArea, Extent), Rows),
        (
            ( predict(Predicted, Area, Perimeter, MajorAxisLength,
                      MinorAxisLength, Eccentricity, ConvexArea, Extent) ->
                format("Sample (MAL=~w, P=~w) -> Predicted=~w | Actual=~w~n",
                       [MajorAxisLength, Perimeter, Predicted, Actual])
            ; format("Sample (MAL=~w, P=~w) -> Could not classify | Actual=~w~n",
                     [MajorAxisLength, Perimeter, Actual])
        )
    )).

% ---------------- Interactive Classification -----------------
classify_userinput :-
    write('--- Raisin Classification System ---'), nl,
    write('Enter Area: '), read(Area),
    write('Enter Perimeter: '), read(Perimeter),
    write('Enter MajorAxisLength: '), read(MajorAxisLength),
    write('Enter MinorAxisLength: '), read(MinorAxisLength),
    write('Enter Eccentricity: '), read(Eccentricity),
    write('Enter ConvexArea: '), read(ConvexArea),
    write('Enter Extent: '), read(Extent),
    (   predict(Predicted, Area, Perimeter, MajorAxisLength,
                 MinorAxisLength, Eccentricity, ConvexArea, Extent)
    ->  nl, write('>>> The raisin is classified as: '), write(Predicted), nl,
        write('--- Classification Completed ---'), nl
    ;   nl, write('No classification rule matched. Please check provided inputs.'), nl
    ).
