#!/bin/sh
#
# Compile the matlab code so we can run it without a matlab license. Required:
#     Matlab 2017a, including compiler, with license

# Run the matlab compiler from the linux command line - it's easier to get the 
# correct punctuation.
#
# Need to -a add some local non-code files that the compiler won't find on its own:
#    report.fig
mcc -m -v src/fmri_conncalc.m \
-a src/report.fig \
-d bin

# Grant lenient execute permissions to the matlab executable and runscript
chmod go+rx bin/ndw_wm_edat
chmod go+rx bin/run_ndw_wm_edat.sh
