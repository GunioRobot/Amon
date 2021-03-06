package DeepNamespace::Web::User::Dispatcher;
use Amon::Web::Dispatcher;
use feature 'switch';

sub dispatch {
    my ($class, $c) = @_;
    given ($c->request->path_info) {
        when ('/') {
            return call("Root", 'index');
        }
        default {
            return res_404();
        }
    }
}

1;
