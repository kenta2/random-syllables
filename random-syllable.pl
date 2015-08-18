#! /usr/bin/perl -w

# Copyright 2015 Ken Takusagawa

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

$iter=2;
$lines=10;

$syllables=1;
open RAND,"/dev/urandom" or die;

@letters=("a".."z");
# is T reachable because of the angled rows?
#@letters=&subtract(\@letters,['t']);
#@letters=&subtract(\@letters,['y','g','h','b','n']);
#@letters=&subtract(\@letters,['y','b']); #long reach
#print @letters;
@vowels=qw/a e i o u/;
@consonants=&subtract(\@letters,\@vowels);
@consonants=&subtract(\@consonants,['q']);

push @consonants,""; #non-three-letter words

push @consonants,('th','ch','sh') ; #ph

@initials=@consonants;
@initials=&subtract(\@initials,['x']);
@initials=&subtract(\@initials,['k']);
#push @initials,qw(wh pr st fr tr cl sp pl sc gr kn cr fl sm);
#push @initials,qw(pr st fr tr cl sp pl sc gr cr fl sm qu);
push @initials,qw(qu);
#kn ps
push @initials,qw( st fr cl tr br cr pr dr sp fl sc sl gr bl pl sm sw sn gl str scr thr spr);


@tails=@consonants;
@tails=&subtract(\@tails,['y','h','w']);
@tails=&subtract(\@tails,['c','k']);
#push @tails,('ng','nd','ll','st','nt','ts','ld','ns','ss','nk','ck','ds','gh') ;
push @tails,qw/st nd nt ns ts ck rt rs ld ls cked ps ds rn ng ms ft rm lt gs rd lf mp lk rl rk bs rg nk lm rb nts nds/;
#avoid silent b in mb, p in pt

push @vowels,qw(oo ee au);
push @vowels,qw(ai ie oa);
# manually do long final e
$shorten{ai}="a";
#$shorten{ee}="e";
$shorten{ie}="i";
$shorten{oa}="o";
$shorten{oo}="u";

@punctuation=(32..126);
#@punctuation=&subtract(\@punctuation,[48..57]);
@punctuation=&subtract(\@punctuation,[65..90]);
@punctuation=&subtract(\@punctuation,[97..122]);
@punctuation=map(chr,@punctuation);
#@punctuation=("7");

#50 b d f g j l m n p r s t v x z  th ch sh st nd nt ns ts ck rt rs ld ls ct ps ds rn ng ms ft rm lt gs rd lf mp lk rl rk bs rg nk lm rb
for(qw(b d f j l m n p r s t v x z  th ch sh st)){
    $long_e{$_}=$_."e";
}
for(@tails){
    next unless ($x,$y)=/^(.)([sd])$/;
    next if $x =~ /[cg]$/;
    die if defined($long_e{$_});
    $long_e{$_}=$x."e".$y;
}
$long_e{ck}="ke";
$long_e{cked}="ked";
$long_e{ft}="fed";
#&lengthprint(@initials);
#&lengthprint(@vowels);
#&lengthprint(@tails);
#&lengthprint(@punctuation);
for(1..$lines){ #num lines
    $_="";
    for$i(1..$iter){
        for$s(1..$syllables){
            #numsyllables.  1 syllable found better than 2 syllables.
            #average syllable length 10760/3080
            #versus 11 punctuation
            $a = &select_random(@initials);
            $b = &select_random(@vowels);
            $c = &select_random(@tails);
            if ($a =~ /c$/ and $b =~ /^[ei]/) {
                $a =~ s/c$/k/;
                #print "got here\n"
            }
            #redo if ($b =~ /[aeiou]{2}/ and $c =~ /^[r]./);
            if ($b=~/^(u|i|oa|au)$/ and $c =~ /^r/) {
                redo;
            };

            if ($b eq "au" and $c eq ""){
                $b="aw";
            }
            if ($b eq "ai" and $c eq ""){
                $b="ay";
            }
            if ($b eq "ie" and $c eq "" and ($a ne "" and $a ne "y")){
                $b="y";
            }
            if ($b eq "oa" and $c eq ""){
                $b="ow";
            }
            if ($a eq "qu" and ($b =~ /^u/ or $b eq "y")){
                $a="kw";
            }
            #redo if ((length$a)+(length$c))>3;
            if (defined($shorten{$b}) and $long_e{$c}){
                unless($a eq "qu" and $shorten{$b} =~ /^u/){
                    $b=$shorten{$b};
                    $c=$long_e{$c};
                }
            }
            if ($c eq "j"){
                if(length($b)==1){
                    $c="dge";
                }else{
                    $c="ge";
                }
            }
            $w=$a.$b.$c;
            $w=~s/(.)je$/$1ge/;
            #$w=~s/x$/cks/;
            $w=~s/xe$/kes/;
            $w=~s/este$/eest/;
            $w=~s/uste$/oost/;
            if ($w =~ /(ie|ai|ee|oo)[lr][^aeiouds]/){
                redo;
                #$w="#".$w;
            }
            #$w="#".$w if ($b=~/^(ie|ai|ee)$/ and $c =~ /^r./);
            $_.=$w;
        }
        $s=0; #quell warning
        $_ .= &select_random(@punctuation);
    }
    $i=0; #quell warning
    #print "$_\n";
    redo unless /\d/;
    redo if / $/;
    print "$_\n";
}
sub lengthprint {
    print scalar@_;
    print " $_" for(@_);
    print "\n";
}
sub subtract {
    my $a=shift;
    my $b=shift;
    my $left;
    my $right;
    my @result;
    for$left(@$a){
        my $ok=1;
        for$right(@$b){
            if($left eq $right){
                $ok=0;
                last;
            }
        }
        if ($ok){
            push @result,$left;
        }
    }
    @result;
}
sub printrefs{

    my $a=shift;
    my $b=shift;
    print @$a,"\n\n";
    print @$b,"\n";
}
sub getrand_maybe{
    my $target=shift;
    my $sample=shift;
    my $m=$sample % $target;
    my $over1 = $target + ($sample - $m);
    if ($over1<=256){
        $m;
    }else{
        -1;
    }
}

sub getrand_test{
    my $target=shift;
    my $sample;
    my @output;
    for$sample(0..255){
        push @output,&getrand_maybe($target,$sample);
    }
    @output;
}

sub getrand{
    my$target=shift;
    my$answer;
    for(;;){
        my$sample=getc RAND;
        $sample=ord$sample;
        $answer=&getrand_maybe($target,$sample);
        last if $answer>=0;
    }
    $answer;
}
sub select_random{
    $_[&getrand(scalar@_)];
}
