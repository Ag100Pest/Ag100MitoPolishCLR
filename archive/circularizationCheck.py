#!/usr/bin/python
#Version: 1.0
#Author: Alex Schomaker - alexschomaker@ufrj.br
#LAMPADA - IBQM - UFRJ

'''
Copyright (c) 2014 Alex Schomaker Bastos - LAMPADA/UFRJ

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

A Stahlke modified and combined mitofinder scripts to run just circularization

'''
import argparse, os, shlex, shutil, sys
import os.path
from argparse import RawTextHelpFormatter
import subprocess
from subprocess import Popen
from Bio import SeqIO, SeqFeature, SeqUtils, SearchIO
from Bio.Alphabet import generic_dna, generic_protein
import glob
from shutil import copyfile
from datetime import datetime
import time
import operator
import collections

circularSize=45 # defaults
circularOffSet=400 # defaults
fourthStep = None #circularization check

resultFile = sys.argv[1]

pathtowork=os.getcwd()
pathOfResult = pathtowork + "/" + resultFile
print(pathOfResult)

def circularizationCheck(resultFile):
	'''
	Check, with blast, if there is a match between the start and the end of a sequence.
	Returns a tuple with (True, start, end) or False, accordingly.
	'''
	refSeq = SeqIO.read(resultFile, "fasta", generic_dna)
	sizeOfSeq = len(refSeq)
	print(sizeOfSeq)
	try:
		command = "makeblastdb -in " + resultFile + " -dbtype nucl" #need to formatdb refseq first
		args = shlex.split(command)
		formatDB = Popen(args, stdout=open(os.devnull, 'wb'))
		formatDB.wait()
	except:
		print ("formatDB during circularization check failed...")
		return (False,-1,-1)
		
	with open("circularization_check.blast.xml",'w') as blastResultFile:
		#if blastFolder == 'installed':
		#	command = "blastall -p blastn -d " + resultFile + " -i " + resultFile + " -m 7" #call BLAST with XML output
		#else:
		command = "blastn -task blastn -db " + resultFile + " -query " + resultFile + " -outfmt 5" #call BLAST with XML output
		args = shlex.split(command)
		blastAll = Popen(args, stdout=blastResultFile)
		blastAll.wait()

	blastparse = SearchIO.parse('circularization_check.blast.xml', 'blast-xml') #get all queries

	'''
	Let's loop through all blast results and see if there is a circularization.
	Do it by looking at all HSPs in the parse and see if there is an alignment of the ending of the sequence 
    with the start of that same sequence. It should have a considerable size, you don't want to say it circularized
	if only a couple of bases matched.
	Returns True or False, x_coordinate, y_coordinate
	x coordinate = starting point of circularization match
	y coordina	te = ending point of circularization match
	'''
	for qresult in blastparse: #in each query...
		for hsp in qresult.hsps: #loop through all HSPs looking for a circularization (perceived as a hsp with start somewhat close to the query finish)
			if (hsp.query_range[0] >= 0 and hsp.query_range[0] <= circularOffSet) and (hsp.hit_range[0] >= sizeOfSeq - hsp.aln_span - circularOffSet and hsp.hit_range[0] <= sizeOfSeq + circularOffSet) and hsp.aln_span >= circularSize and hsp.aln_span < sizeOfSeq * 0.90:
				if hsp.hit_range[0] < hsp.query_range[0]:
					fourthStep=[True,hsp.hit_range[0],hsp.hit_range[1]]
					return fourthStep
				else:
					fourthStep=[True,hsp.query_range[0],hsp.query_range[1]]
					return fourthStep
					
	#no circularization was observed in the for loop, so we exited it, just return false
	return (False,-1,-1)

fourthStep=circularizationCheck(sys.argv[1])
print(fourthStep)

resultFile = 'circularized' + pathOfResult

if fourthStep[0] == True:
	print ('Evidences of circularization were found!')
	print ('Sequence is going to be trimmed according to circularization position')
	print ('Trimming', fourthStep[2], 'bp')
	with open(resultFile, "w") as outputResult: #create draft file to be checked and annotated
		finalResults = SeqIO.read(open(pathOfResult, 'rU'), "fasta", generic_dna)
		finalResults.seq = finalResults.seq[int(fourthStep[2]):].upper()
		count = SeqIO.write(finalResults, outputResult, "fasta") #trims according to circularization position
else:
	print ('Evidences of circularization could not be found, but everyother step was successful')
	with open(resultFile, "w") as outputResult: #create draft file to be checked and annotated
		finalResults = SeqIO.read(open(pathOfResult, 'rU'), "fasta", generic_dna)
		finalResults.seq = finalResults.seq.upper()
		count = SeqIO.write(finalResults, outputResult, "fasta") #no need to trim, since circularization wasn't found          

print ('Done!') 
