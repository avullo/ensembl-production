
=head1 LICENSE

Copyright [2009-2016] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language govern ing permissions and
limitations under the License.

=cut

package Bio::EnsEMBL::Production::Pipeline::Search::ReformatGenomeSolr;

use strict;
use warnings;

use base qw/Bio::EnsEMBL::Production::Pipeline::Common::Base/;

use Bio::EnsEMBL::Utils::Exception qw(throw);

use Bio::EnsEMBL::Production::Search::GenomeSolrFormatter;

use JSON;
use File::Slurp qw/read_file/;
use Carp qw(croak);

use Log::Log4perl qw/:easy/;
use Data::Dumper;

sub run {
	my ($self) = @_;
	if ( $self->debug() ) {
		Log::Log4perl->easy_init($DEBUG);
	}
	else {
		Log::Log4perl->easy_init($INFO);
	}
	$self->{logger} = get_logger();
	my $genes_file     = $self->param_required('genes_file');
	my $genome_file    = $self->param_required('genome_file');
	my $genome = decode_json(read_file($genome_file));

	my $species        = $self->param_required('species');
	my $sub_dir        = $self->get_data_path('solr');

	my $genes_file_out = $sub_dir . '/' . $species . '_genes.json';
	my $transcripts_file_out = $sub_dir . '/' . $species . '_transcripts.json';
	my $reformatter    = Bio::EnsEMBL::Production::Search::GenomeSolrFormatter->new();
	$self->{logger}->info("Reformatting $genes_file into $genes_file_out");
	$reformatter->reformat_genes($genes_file, $genes_file_out, $genome, 'core');
	$reformatter->reformat_ids($genes_file, $genes_file_out, $genome, 'core');
	$reformatter->reformat_sequences($genes_file, $genes_file_out, $genome, 'core');
	$reformatter->reformat_transcripts($genes_file, $transcripts_file_out, $genome, 'core');
	$reformatter->reformat_gene_families($genes_file, $genes_file_out, $genome, 'core');
	$reformatter->reformat_gene_trees($genes_file, $genes_file_out, $genome, 'core');


	
	$reformatter->reformat_lrgs($genes_file, $genes_file_out, $genome, 'core');
	$reformatter->reformat_markers($genes_file, $genes_file_out, $genome, 'core');
	$reformatter->reformat_domains($genes_file, $genes_file_out, $genome, 'core');
	return;
}

1;
