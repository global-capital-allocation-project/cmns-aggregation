# ---------------------------------------------------------------------------------------------------
# CMNS ultimate parent aggregation algorithm: Manual corrections for data errors
#
# The files in this folder provide an implementation of the ultimate parent aggregation algorithm of 
# Coppola, Maggiori, Neiman, and Schreger (2019). For a detailed discussion of the aggregation algorithm, 
# please refer to the paper.
#
# This file implements a number of manual correction to the raw data, which address mistaken reporting.
# Note that these corrections are not meant to be comprehensive, but rather reflect the errors that
# we became aware of in the course of the project.
# ---------------------------------------------------------------------------------------------------

# CUSIP6 codes to be dropped from source
drop_cusip6 = {
    
    # Capital IQ
	'ciq': [
		'92857W',	# Reference to outdated Vodafone-Thales link
 		'45579E',	# Bad info for Indivior
 		'G4766E',	# Bad info for Indivior
        '761735',   # Incorrect Reynolds group link to NZL
        'G9001E',   # Incorrect link of Liberty Media to Liberty Media LatAm
        '16943U',   # Incorrect Sinopec link to USA
        '62629V',   # Incorrect attribution of St. Zachary municipality (Quebec) to USA
        '92716Y',   # Incorrect attribution of St. Colomban municipality (Quebec) to FRA
	],
    
    # SDC Platinum
	'sdc': [
		'46647P',	# Incorrect JP Morgan link to GBR
        'F0609N',   # AXA: Incorrect link to USA
        '453140',   # Incorrect Imperial Tobacco assignment to DEU
        'E8471S',   # Incorrect Repsol assignment to CHN
        '00507V',   # Reference to outdated Activision-Blizzard link to FRA
        'G2018Z',   # Reference to outdated Centrica-British Gas link
        'F6866T'    # Incorrect link of Orange (FRA) to Staples (USA)
    ],
    
    # Orbis
    'bvd': [
        # Tencent: This is an incorrect attribution to Naspers, as there is no 50% stake;
        # there is also no record of this in the online Orbis database, so most likely an
        # error in the data that we received
        "G87572",
        "Y6883Q",   # Incorrect attribution of PetroChina to ChangFeng
        "448055",   # Incorrect attribution of Husky Energy to Orient Overseas (not in online platform)
        "Q2818G"     # Outdated link of Contact Energy (NZL) to Origin Energy
    ],
    
    # Dealogic
    'dlg': [
        '89236T',    # Bad Toyota info (to USA)
        'T5R13H',    # Bad Intesa Sanpaolo info (to GBR)
        '135087',    # Bad Canadian Government info (to GBR)
        'R3S83B',    # Incorrect assignment of Kummuninvest Sweden to NOR
    ],
    
    # Factset
    'fds': [],
    
    # CGS Associated Issuers
    'ai': [
        'Y49650',    # Bad KfW info (to THA)
        '001907',    # Bad Samsung info (to USA) 
        'F0R724',    # Incorrect attribution of AIG to FRA
        '806857',    # Outdated attribution of Schlumberger to Faultfinders
        '465326',    # Incorrect attribution of Italian sovereign bonds to USA
        '44107P',    # Attribution of Host Hotels to Sodexo (there is no ownership link)
        'R3S83B',    # Incorrect assignment of Kummuninvest Sweden to NOR
        '825247',    # Shorewood Winsconsin munis to CAN
        'Y2034L',    # DZ-Hyp (DEU) to KOR
        'Q4876K'     # Incorrect attribution of Australia National Bank to Indago Energy
    ],
    
    # Morningstar Country Reports
    'ms': [
        '575909',   # Incorrect assignment of Massachusetts munis to BRA
        '492693',   # Incorrect assignment of Ohio munis to NOR
        '059612',   # Incorrect assignment of Bancomext to USA
        '03938L',   # Attribution of ArcelorMittal (LUX) to USA
        'L0302D',   # Attribution of ArcelorMittal (LUX) to USA
        '02154V',   # Attribution of Altice (LUX/FRA) to USA
        'V7179R',   # Attribution of Seychelles sovereign bonds to USA
        'T35329',   # Attribution of Dow Chemical to BRA
        'G397JM'    # Attribution of Goldman International to SAU
    ]
}

# Cosmetic updates: List of outdated names for certain issuer numbers, 
# which are replaced with names from other sources
outdated_names = {
    'cgs': [
        'G4209W'    # Experian (old name is GUS)
    ]
}
