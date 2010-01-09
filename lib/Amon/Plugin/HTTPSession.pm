package Amon::Plugin::HTTPSession;
use strict;
use warnings;
use HTTP::Session;
use Amon::Util;

sub init {
    my ($class, $c, $conf) = @_;

    my $state_code = $class->_load($conf->{state}, 'HTTP::Session::State');
    my $store_code = $class->_load($conf->{store}, 'HTTP::Session::Store');

    $c->add_method(session => sub {
        my $self = shift;
        $self->pnotes->{session} ||= do {
            HTTP::Session->new(
                state   => $state_code->(),
                store   => $store_code->(),
                request => $self->request,
            );
        };
    });
    $c->add_trigger(AFTER_DISPATCH => sub {
        my ($self, $res) = @_;
        if (my $session = $self->pnotes->{session}) {
            $session->response_filter($res);
            $session->finalize();
        }
    });
}

sub _load {
    my ($class, $stuff, $namespace) = @_;
    if (ref $stuff) {
        if (ref $stuff eq 'CODE') {
            return $stuff;
        }
        elsif ( ref $stuff eq 'ARRAY' ) {
            my $store_class = Amon::Util::load_class($stuff->[0], $namespace);
            my $store_obj = $store_class->new( %{ $stuff->[1] } );
            return sub { $store_obj };
        }
        else {
            return sub { $stuff };
        }
    } else {
        my $store_class = Amon::Util::load_class($stuff, $namespace);
        my $store_obj = $store_class->new();
        return sub { $store_obj };
    }
}

1;
__END__

=head1 NAME

Amon::Plugin::HTTPSession - Plugin system for Amon

=head1 SYNOPSIS

    package MyApp::Web;
    use Amon::Web -base;
    __PACKAGE__->load_plugins( 'HTTPSession', 
        {
            state => [ 'Cookie', { cookie_key => 'foobar' } ],
            store => [ 'File',   { dir        => '/tmp/' }  ],
        }
    );

    package MyApp::C::Root;
    use Amon::Web::C;
    sub index {
        my $foo = c->session->get('foo');
        if ($foo) {
              c->session->set('foo' => $foo+1);
        } else {
              c->session->set('foo' => 1);
        }
    }

=head1 DESCRIPTION

HTTP::Session integrate to Amon.

After load this plugin, you can get instance of HTTP::Session from C<c->session> method.

=head1 SEE ALSO

L<HTTP::Session>

=cut

