# Almost Norm-Euclidean

## Introduction

David A. Clark's "A Quadratic Field which is Euclidean but not Norm-Euclidean" proved that $\mathbb{Q}[\sqrt{69}]$ is Euclidean with respect to a norm that is almost the absolute value of the usual field norm. His approach in this paper was partly computational, since he showed that there are only a finite number of points in the ring of integers of $\mathbb{Q}[\sqrt{69}]$ for which the field norm _is not_ Euclidean. Additionally, he showed that altering the field norm so that those finite "bad" points became good did not break the norm for any of the other points. 

This repository contains code that replicates this same search for discriminants other than 69. It focuses on the first step of Clark's proof, namely identifying the "bad" points for which the field norm is not quite Euclidean. This work has been done with the Computational Number Theory seminar at BYU.

## Background

Let $\Delta$ be the discriminant of our quadratic field. For our purposes, we will also require $\Delta > 0$. We write this field as $K = \mathbb{Q}[\sqrt{\Delta}]$. Then the ring of integers, $\mathcal{O}_ {K}$, looks like

$$
    \mathcal{O}_ {K} = 
    \begin{cases}
        \mathbb{Z}[\sqrt{\Delta}] \qquad &\text{if } \Delta \equiv 2,3 (\text{mod } 4) \\
        \mathbb{Z}[\sqrt{\frac{1 + \Delta}{2}}] \qquad &\text{if } \Delta \equiv 1 \text{ (mod} 4).
    \end{cases}
$$

It is known that $\mathcal{O}_ {K}$ is a Euclidean domain. In particular, this means that there is a function $\nu : \mathcal{O}_ {K} \to \mathbb{Z}_ {\geq 0}$ such that for any $a, b \in \mathcal{O}_ {K}$, there exists $q, r \in \mathcal{O}_ {K}$ satisfying

$$
    a = bq + r,
$$

where either $r = 0$ or $\nu(r) < \nu(b)$.

As a concrete example of this, the integers are a Eucliden domain, where $\nu$ is just the usual absolute value function.

Now, if $\Delta \equiv 1 (\text{mod } 4)$, let $\alpha = \frac{1 + \sqrt{\Delta}}{2}$. Otherwise, let $\alpha = \sqrt{\Delta}$. Then the field norm is defined to be

$$
    N(x + \alpha y) = (x + \alpha y) \cdot (x + \overline{\alpha} y),
$$

where $\overline{\alpha} = \frac{1 - \sqrt{\Delta}}{2}$ or $\overline{\alpha} = -\sqrt{\Delta}$, respectively.

For $\mathcal{O}_ {K}$, if we can take $\nu$ (the Euclidean function) to be the absolute value of the field norm, then we say that $\mathcal{O}_ {K}$ is Norm-Euclidean.

The number of discriminants for which this holds is finite, and completely known. For the other discriminants, we want to know if we can alter the field norm just enough so that $\mathcal{O}_ {K}$ is almost Norm-Euclidean. Clark did this for $\Delta = 69$.


## How do we do this?

Clark's argument can be broken up into two parts:
1. identify the "bad" regions,
2. show that altering the norm to make these "bad" regions good does not affect the previously good regions.

We focus on the first part of this argument in this code.

To identify "bad" regions, we need to find points for which $q$ and $r$ (from above) do _not_ exist when $\nu$ is the absolute value of the field norm. Because the field norm $N$ is completely multiplicative, we can rewrite the condition that $a = bq + r$ like so:

$$
\begin{align*}
    a = bq + r &\implies \frac{a}{b} - q = \frac{r}{b} \\
    &\implies |N(\frac{a}{b} - q)| = |N(\frac{r}{b})| < 1.
\end{align*}
$$

Notice that $a,b,q \in \mathcal{O}_ {K}$, so we can write each of these as $m + \alpha n$, where $m, n \in \mathbb{Z}$. In particular, this means that we can rewrite the above as

$$
\begin{align*}
    1 &> |N(\frac{a}{b} - q)| \\
    &= |N(\frac{a_{1} + \alpha a_{2}}{b_{1} + \alpha b_{2}} - (q_{1} + \alpha q_{2})| \\
    &= |N(x + \alpha y) - (q_{1} + \alpha q_{2})| \\
    &= |N((x - q_{1}) + \alpha (y - q_{2}))|,
\end{align*}
$$

where now $x,y \in \mathbb{Q}$ and $q_{1}, q_{2} \in \mathbb{Z}$.

Because of this, we need only consider $x,y \in [0,1]$; to get to any other rational number, we just shift by an integer. This is equivalent to just adding the necessary shift to $q_{1}$ and $q_{2}$ though, and so it suffices to consider only $x$ and $y$ from a unit square.

Now the problem of identifying "bad" regions is equivalent to identifying rational numbers $x$ and $y$ for which there is _no_ integer shift $q_{1}, q_{2}$ so that

$$
    |N((x - q_{1}) + \alpha (y - q_{2}))| < 1.
$$

## Implementation

We start with an input square. In practice, we've used the unit square with bottom left corner at the origin $([0,1] \times [0, 1])$. The program takes this inputted square and cuts it into fourths. It calculates the maximum possible norm (meaning, the absolute value of the field norm) over each of these four squares. If that norm is less than one, then we know that the unaltered field norm works for every point in that box. If the maximum norm is greater than one, then there may be points in that box that the field norm does _not_ work for. We write these "bad" boxes to a file, and then the program recurses on each of these "bad" boxes (breaking them into fourths, and so on). 

With each recursion, the "bad" boxes get smaller, and so we're zooming in on regions that contain possible "bad" points. For discriminants that _are_ Norm-Euclidean, this process will eventually terminate, since there will be no bad boxes after a finite number of recursions. 

## How to use

To run the actual computation that identifies possible bad regions, run `parallel_norm.sage` using sage. This program takes in the directory that you want the files with the "bad" squares saved to, a discriminant, a translate, and the number of CPUs you want the program to run on. 

The discriminant should be a positive, squarefree integer. The translate should also be a positive integer; this number will determine how far the points in your input square will be translated during each recursive step. A translate of 10 means that $q_ {1} \in [-10, 10]$ and $q_ {2} \in [-10, 10]$, so the program will try at most 400 possible translations of a given point in the unit square.

You can also add an optional input file, which should be a file of previously computed "bad" squares. This means that you do not need to redo previous computations. If no input file is passed in, the program will start with the input square.

You can also add an optional input square; this option is available because the bad regions for certain discriminants fall along the border of the $[0,1] \times [0,1]$ square, and so shifting to a different unit square makes the image clearer. If no input square is passed in, the program will just use the square given by $[0,1] \times [0,1]$.

Once you have files with "bad" squares, you can use the `plot_from_file.sage` program to see what the "bad" regions look like. This program takes in the name of the file that contains the "bad" squares you want plotted, and a name for the file where your image will be saved. 

<!--This code is written in Sagemath. It uses the packages matplotlib, json, numpy, os, argparse, multiprocessing, and warnings.-->
