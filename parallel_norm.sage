import json
import matplotlib.pyplot as plt
import numpy as np
import matplotlib.patches as patches
import os
import argparse
from multiprocessing import Pool
import warnings

warnings.filterwarnings("ignore", category=DeprecationWarning) 


"""

-----------------
|       |       |
|       |       |
|       |       |
--------0--------
|       |(x,y)  |
|       |       |
|       |       |
-----------------

[_______]
  step

"""

def n_max(x, y, step, disc): 
    # find max norm of square with center (x,y)
    # where the sidelength of the square is 2*step
    xl,yl,xh,yh = x-step, y-step, x+step, y+step

    if disc % 4 == 1:
        val = (disc - 1)/(-4)
        N(X,Y) = abs(X**2 + X*Y + val*Y**2)
        edges = [N(xl,yl), N(xl,yh), N(xh,yl), N(xh,yh)] # corners

        # now check critical points along edges, only adding if they are contained in box
        if yl <= xl/(-2*val) and xl/(-2*val) <= yh:
            edges.append(N(xl,xl/(-2*val)))
        if yl <= xh/(-2*val) and xh/(-2*val) <= yh:
            edges.append(N(xh,xh/(-2*val)))
        if xl <= (-yl/2) and (-yl/2) <= xh:
            edges.append(N(-yl/2,yl))
        if xl <= (-yh/2) and (-yh/2) <= xh:
            edges.append(N(-yh/2,yh))

    elif disc % 4 == 2 or disc % 4 == 3:
        N(X,Y) = abs(X**2 - disc*Y**2)
        edges = [N(xl,yl), N(xl,yh), N(xh,yl), N(xh,yh)] # corners

        # now check critical points along edges, only adding if they are contained in box
        if yl == 0:
            edges.append(N(xl,0))
            edges.append(N(xh,0))
        if xl == 0:
            edges.append(N(0,yl))
            edges.append(N(0,yh))

        # add xh , yh

    else: raise Error("Not a valid discriminant.")

    return max(edges)


def check(x, y, step, disc):
    # check if max norm over box is less than 1
    return (n_max(x, y, step, disc) < 1)


def int_translates(x, y, step, translate, disc):
    # run check on translates of a given square
    for x0 in range(-translate, translate):
        for y0 in range(-translate, translate):
            if check(x + x0, y + y0, step, disc):
                return True

    return False 


"""

0----------------------0----------------------0
|(xl,yh)               |(xl+step,yh)          |(xh,yh)
|                      |                      |
|                      |                      |
|                      |                      |
|                      |                      |
|                      |                      |
|                      |                      |
|                      |                      |
|                      |                      |
|                      |                      |
0----------------------0----------------------0
|(xl,yl+step)          |(xl+step,yl+step)     |(xh,yl+step)|
|                      |                      |
|                      |                      |
|                      |                      |
|                      |                      |
|                      |                      |
|                      |                      |
|                      |                      |
|                      |                      |
|                      |                      |
0----------------------0----------------------0
 (xl,yl)                (xl+step,yl)           (xh,yl)

[______________________]
          step

"""

# we record squares as lists: square = [xlow, ylow, xhigh, yhigh]

def explore_square(bad_squares, translate, disc):
    # this function is called in `loop`, which will only 
    # pass a single bad square at a time (in a list though)
    new_bad_squares = list()

    # given a bad square, break it into its four subsquares and 
    # check if these are bad
    for square in bad_squares:
        xl, yl, xh, yh = square
        step = (xh - xl) / 2
        assert (step == (yh - yl) / 2) # since square

        # cut bad square into four subsquares 
        # and find max norm on those subsquares
        for sub_square in [[xl, yl, xl+step, yl+step], [xl+step, yl, xh, yl+step], [xl, yl+step, xl+step, yh], [xl+step, yl+step, xh, yh]]:
            ss_step = step/2
            ss_xl, ss_yl, ss_xh, ss_yh = sub_square
            center = (ss_xl + ss_step, ss_yl + ss_step)
            small_enough = int_translates(center[0], center[1], ss_step, translate, disc)

            # if max norm for subsquares too big,
            # add subsquare to new_bad_squares list
            if not small_enough:
                new_bad_squares.append((ss_xl, ss_yl, ss_xh, ss_yh))

    return new_bad_squares


def loop(output_dir, bad_squares, input_square, translate, disc, num_cpus):
    # loop explore_square
    p = Pool(num_cpus)
    depth = 1 

    flag = True
    # will loop indefinitely as written; you can add a break condition in the while loop
    # or just ctrl-c out of the program (progress is saved in files, so recursions completed
    # before the program is cancelled are not lost)
    while flag:
        stacked_bad_squares = p.starmap(explore_square, [([sq], translate, disc) for sq in bad_squares])
        bad_squares = []
        for s in stacked_bad_squares: # stripping away one level of list-ness to get in right format
            bad_squares.extend(s)

        # write bad_squares 
        write_bad_squares(output_dir, bad_squares, input_square, disc, depth, translate)

        print(f'Finished discriminant {disc}, depth {depth}, translate {translate}')
        depth += 1

    return


def write_bad_squares(output_dir, bad_squares, input_square, disc, depth, translate):
    bad_squares = [(str(bad_squares[i][0]), str(bad_squares[i][1]), str(bad_squares[i][2]), str(bad_squares[i][3])) for i in range(len(bad_squares))]
    f = open(f'{output_dir}/disc{disc}_depth{depth}.txt', 'w')
    print(f'Writing to {output_dir}/disc{disc}_depth{depth}.txt')
    str_input_sq = [str(val) for val in input_square]
    f.write(json.dumps({"depth": str(depth), "translate": str(translate), "input_square": str_input_sq, "squares": bad_squares}))
    f.close()
    return


def read_bad_squares(input_file):
    assert os.path.exists(input_file)
    f = open(input_file, 'r')
    print(f'Reading from {input_file}')
    bad = f.read()
    f.close()

    square_dict = json.loads(bad)
    str_bad_squares = square_dict["squares"]
    if "input_square" in square_dict:
        input_square = [Rational(val) for val in square_dict["input_square"]]
    else:
        input_square = [0,0,1,1]
    bad_squares = []

    for str_sq in str_bad_squares:
        assert len(str_sq) == 4 # should look like [xl, yl, xh, yh]

        sq = [Rational(str_sq[0]), Rational(str_sq[1]), Rational(str_sq[2]), Rational(str_sq[3])]
        bad_squares.append(sq)

    return bad_squares, input_square


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('-o', '--output-directory', required=True, help='The name of the directory you want each bad squares file saved')
    ap.add_argument('-f', '--input-file', required=False, help='The name of the file where your starting bad squares are')
    ap.add_argument('-d', '--discriminant', required=True, type=int, help='The discriminant of the number field')
    ap.add_argument('-t', '--translate', required=True, type=int, help='The range you want for translates')
    ap.add_argument('-c', '--num-cpus', required=True, type=int, help='The number of CPUs you want to use')
    ap.add_argument('-i', '--input-square', required=False, nargs=argparse.REMAINDER, type=str, default=["0","0","1","1"], help='The 1x1 square you initialize the computation with')
    args = ap.parse_args(sys.argv[1:])
    
    # make output directory (fails if directory already exists)
    os.makedirs(args.output_directory)

    if args.input_file != None:
        print("Since you specified an input file, we'll use the input square stored in that file, and not the one you may have passed to the parser.")

    assert (len(args.input_square) == 4)

    # initialize list of bad squares
    # either read in from a file, or start with unit square centered at (1/2, 1/2)
    if args.input_file == None:
        bad_squares = [[Rational(num) for num in args.input_square]] # [[Rational(-1/2), 0, Rational(1/2), 1]] # [[0,0,1,1]]
        input_square = [Rational(num) for num in args.input_square]
    else:
        bad_squares, input_square = read_bad_squares(args.input_file)

    # start cutting up squares and recursing
    loop(args.output_directory, bad_squares, input_square, args.translate, args.discriminant, args.num_cpus)

