# ---------------------------------------------------------------------------------------------------
# CMNS ultimate parent aggregation algorithm: Project constants
#
# The files in this folder provide an implementation of the ultimate parent aggregation algorithm of 
# Coppola, Maggiori, Neiman, and Schreger (2019). For a detailed discussion of the aggregation algorithm, 
# please refer to the paper.
#
# This file defines constants that are used by the code in UP_Aggregation.py.
# 
# Technical notes:
#   - Prior to running the procedure, please be sure to fill in the following parameter in the script:
#           <DATA_PATH>: Path to the folder containing the data, in which the procedure is executed
# ---------------------------------------------------------------------------------------------------

# Path to folder structure holding the data, in which the procedure is executed
data_path = "<DATA_PATH>"

# List of countries classified as tax havens
tax_havens = [
	"ABW", "AIA", "AND", "ANT", "ATG", "BHS", "BLZ", "BMU", "BRB", "BRN", "COK", "CPV", 
	"CUW", "CYM", "DMA", "GGY", "GIB", "GRD", "HKG", "IMN", "JEY", "KNA", "LIE", "MAC", 
	"MCO", "MHL", "MSR", "NIU", "NRU", "PAN", "PLW", "SHN", "SMR", "SYC", "TCA", "TUV", 
	"VCT", "VGB", "VIR", "VUT", "WLF", "WSM", "FRO", "FJI", "GRL", "GUM", "MDV", "MNE", 
	"NCL", "WSM", "LCA", "LUX", "MLT", "ASC", "CCK", "DJI", "FLK", "PYF", "GIB", 
	"GUY", "KIR", "CXR", "NFK", "MNP", "PCN", "SPM", "SLB", "TKL", "TON"
]
