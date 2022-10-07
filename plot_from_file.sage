import os
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import json
import argparse

def read_bad_squares(input_file):
    assert os.path.exists(input_file)
    f = open(input_file, 'r')
    print(f'Reading from {input_file}')
    bad = f.read()
    f.close()

    # str_bad_squares = json.loads(bad)["squares"]
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


def plot_bad_squares(bad_squares, input_square, plot_file): 
    fig, ax = plt.subplots(figsize = (10,10))
    ax.set_aspect("equal")

    for square in bad_squares:
        xl, yl, xh, yh = square
        if ax is not None:
            p = patches.Rectangle((xl, yl), xh - xl, yh - yl, linewidth=.2, edgecolor='k', facecolor='b')
            ax.add_patch(p)

    bounds_xl, bounds_yl, bounds_xh, bounds_yh = input_square
    ax.set_xlim(bounds_xl, bounds_xh)
    ax.set_ylim(bounds_yl, bounds_yh)

    plt.xticks([bounds_xl, bounds_xh])
    plt.yticks([bounds_yl, bounds_yh])
    plt.savefig(plot_file)
    plt.show()
    return 


# def file_plot(plot_file):
    # return plot_bad_squares(bad_squares, plot_file)


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('-f', '--input-file', required=True, help='The name of the file containing the bad squares you want plotted')
    ap.add_argument('-p', '--plot-file', required=True, help='The name of the file you want your square image saved')
    args = ap.parse_args(sys.argv[1:])

    bad_squares, input_square = read_bad_squares(args.input_file)
    # file_plot(args.plot_file)
    plot_bad_squares(bad_squares, input_square, args.plot_file)

