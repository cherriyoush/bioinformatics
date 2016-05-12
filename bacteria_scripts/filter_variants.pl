#!/usr/bin/perl -w

# Applies the same filters as map_snp_call to a vcf

use strict;
use warnings;

use Getopt::Long;
use File::Spec;

# Allows use of perl modules in ./
use Cwd 'abs_path';
use File::Basename;
use lib dirname( abs_path $0 ) . "/../assembly_scripts";
use lib dirname( abs_path $0 );

use File::Copy qw(copy);

use mapping;

# VCF filters
my @vcf_filters = ("FORMAT/DP < 4" , "(GT=\"0\" && PL[0]/PL[1] > 0.75) || (GT=\"1\" && PL[1]/PL[0] > 0.75)", "QUAL < 50", "MQ < 30", "PV4[*] < 0.001", "MQSB < 0.001", "RPB < 0.001");
my @vcf_filter_names = ("DEPTH", "RATIO", "VAR_QUAL", "MAP_QUAL", "PV4_BIAS", "MQ_BIAS", "RP_BIAS");

my $usage_message = <<USAGE;
Usage: ./filter_variants.pl -v <vcf_file>

Applies basic filters to variants in a VCF. Modifies the FILTER field in the VCF provided
USAGE

#* gets input parameters
my ($input_vcf, $help);
GetOptions("vcf|v=s"  => \$input_vcf,
            "help|h"     => \$help
          ) or die($usage_message);

if (defined($help) || !-e $input_vcf)
{
   print $usage_message;
}
else
{
   # Filter variants
   copy $input_vcf, "tmp$input_vcf";
   mapping::filter_vcf($input_vcf, \@vcf_filters, \@vcf_filter_names);

   if ($input_vcf =~ /^(.+_variant)\.bcf$/)
   {
      rename $input_vcf, "$1.filtered.vcf.gz";
   }
   else
   {
      rename $input_vcf, "filtered.$input_vcf.vcf.gz";
   }
   rename "tmp$input_vcf", $input_vcf;
}

exit(0);

