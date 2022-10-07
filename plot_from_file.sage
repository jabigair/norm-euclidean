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

    str_bad_squares = json.loads(bad)["squares"]
    bad_squares = []

    for str_sq in str_bad_squares:
        assert len(str_sq) == 4 # should look like [xl, yl, xh, yh]

        sq = [Rational(str_sq[0]), Rational(str_sq[1]), Rational(str_sq[2]), Rational(str_sq[3])]
        bad_squares.append(sq)

    return bad_squares


def plot_bad_squares(bad_squares, plot_file): # overload?
    fig, ax = plt.subplots(figsize = (10,10))
    ax.set_aspect("equal")

    for square in bad_squares:
        xl, yl, xh, yh = square
        if ax is not None:
            p = patches.Rectangle((xl, yl), xh - xl, yh - yl, linewidth=.2, edgecolor='k', facecolor='b')
            ax.add_patch(p)

    plt.xticks([])
    plt.yticks([])
    plt.savefig(plot_file)
    plt.show()
    return 


def file_plot(plot_file):
    return plot_bad_squares(bad_squares, plot_file)


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('-f', '--input-file', required=True, help='The name of the file containing the bad squares you want plotted')
    ap.add_argument('-p', '--plot-file', required=True, help='The name of the file you want your square image saved')
    args = ap.parse_args(sys.argv[1:])

    bad_squares = read_bad_squares(args.input_file)
    file_plot(args.plot_file)

