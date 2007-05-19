package Cache::Funky;

use warnings;
use strict qw( subs );
use Carp;
use UNIVERSAL::require;

use version; our $VERSION = qv('0.0.3');

sub setup {
    my $class        = shift;
    my $storage      = shift;    
    my $storage_args = shift;

    croak("setup() is a class method, not an object method") if ref $class;
    
    my $storage_class = __PACKAGE__ . "::$storage";
    $storage_class->require or croak $@;
    
    my $storage_obj = $storage_class->new( $storage_args );

    *{ $class . '::_storage' } = sub { $storage_obj };
}

sub register {
    my $class     = shift;
    my $attribute = shift;
    my $code      = shift;

    croak("register() is a class method, not an object method") if ref $class;
    croak("you need args of attribute") if !defined $attribute;
    croak("you need args of coderef")   if !defined $code or ref $code ne 'CODE';

    my $package_attribute = $class . '::' . $attribute;
    *{ $package_attribute }
        = sub {
            my $self = shift;

            my $data;
            unless ( $data = $self->_storage->get( $package_attribute ) ) {
                $data = $code->();
                $self->_storage->set( $package_attribute, $data );
            }

            return $data;
          };
}

sub delete {
    my $self = shift;
    my $attributes;
    
    if ( @_ ) {
        # * convert args to array ref :-)
        $attributes = [ @{ @_ > 1 ? [@_] : ref $_[0] ? $_[0] : [$_[0]] } ];
    }
    else {
        croak("you need args of attribute(s)");
    }

    for my $attribute ( @$attributes ) {
        my $package_attribute = ( ref $self || $self ) .'::'. $attribute;
        $self->_storage->delete( $package_attribute );
    }
}

1; # Magic true value required at end of module
__END__

=head1 NAME

Cache::Funky - How is simple, convenient cache module?

=head1 SYNOPSIS

    package MyCache;

    use strict;
    use warnings;
    use base qw( Cache::Funky );
    
    __PACKAGE__->setup( 'Storage::Memcached' => \%memcacged_conf );
    __PACKAGE__->register( 'foo', sub { `date` } ); # * date: Tue May  1 21:53:36 JST 2007

    1;

    ------

    #! perl
    use strict;
    use warnings;
    use MyCache;

    print MyCache->foo;    # * Tue May  1 21:53:36 JST 2007
    
    sleep 10;
    print MyCache->foo;    # * Tue May  1 21:53:36 JST 2007
    
    MyCache->delete(qw/ foo /);
    print MyCache->foo;    # * Tue May  1 21:53:36+? JST 2007 is NOW!

=head1 METHOD

=head2 setup( 'Storage::*' => $args )

Please set the storage name which you use and the information that the storage class needs.
Please refer to POD of a storage class which information is necessary.

=head2 register( $attribute, $CODE_ref )

Please set an acquisition method of a attribute and data to register with your class.

=head2 delete( $attribute )

Please set the attribute that I want to delete. I can appoint plural attributes. 

=head1 AUTHOR

Masahiro Funakoshi  C<< <masap@cpan.org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007, Masahiro Funakoshi C<< <masap@cpan.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
