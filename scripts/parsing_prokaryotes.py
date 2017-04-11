#!/usr/bin/env python
#-*- coding: utf-8 -*-


import sys
#Ce script traite une chaine de caractère (corresponds à une ligne du gros fichier prokaryotes.txt)

def split_col(string): #fonction qui prends la colonne d'accession et return une liste de reference d'accession des chromosomes et plasmids
	ref_accession = []
	if string == "-":
			return []
	else:
		if ";" in string:
			ref_accession = string.split(';')
			
		else:
			ref_accession.append(string)
	return ref_accession
def find_accession(liste_ref_accession): #Elle prends la liste des chromosomes et plasmids et return la liste des accessions des chromosomes
	accession_chromosom = []
	for i in liste_ref_accession:
		
		s = ""
		if "chromosome" in i:
			if "/" not in i:
			
				pos1 = i.find(':')
				s = i[pos1+1: len(i)]
				accession_chromosom.append(s)
			
			elif "/" in i:
				pos2 = i.find('.')
				pos1 = i.find('/')
				s = i[pos1+1: pos2]
				accession_chromosom.append(s)
		else:
			pass

				
	return accession_chromosom

def parsing(string): #Elle parse le gros fichier prokaryotes, prends la colonnes des accessions, fait appel aux fonctions au dessus et ecrit dans le 			      fichier de sortie les référence accession des chromosomes et le TaxId des souche, Elle traite ligne par ligne 
	string = str(string)
	liste = []
	lst = []
	liste = string.split('\t')	
	#print(len(liste))
	chaine = liste[8]
	TaxId = liste[1]
	#chaine = chaine + '\n'
	#chn = "\n".join(liste)
	liste = split_col(chaine)
	#chn = "\n".join(liste)
	#chn = chn+ '\n\n\n'
	lst = find_accession(liste)
	chain = "\n".join(lst)
	#chain = chain+ '\n\n\n'
	#souche_info = TaxId + '\n' + chain + '\n'
	
	return chain


for line in sys.stdin:
    sys.stdout.write(parsing(line))


