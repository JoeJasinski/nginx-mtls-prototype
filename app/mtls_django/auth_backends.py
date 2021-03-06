import logging
import ast
from urllib.parse import urlparse
from django.conf import settings
from django.contrib.auth.backends import RemoteUserBackend
from django.contrib.auth.models import User
from django.contrib.auth.middleware import RemoteUserMiddleware
from django.contrib import auth
from django.contrib.auth import load_backend
from django.contrib.auth.backends import RemoteUserBackend
from django.core.exceptions import ImproperlyConfigured

logger = logging.getLogger(__name__)


def stringlist_to_list(mtls_header_sl):
    try:
        return ast.literal_eval(mtls_header_sl)
    except (ValueError, SyntaxError) as e:
        logger.warning("unable to parse header: %s", str(e))
        return None


def first_in_list(l):
    try:
        if isinstance(l, dict):
            l = {i: l[i] for i in l if i == 'spiffe://'}
        return next(iter(l), None)
    except (TypeError, ) as e:
        logger.warning("get next header: %s", str(e))
        return None


def parse_mtls_header(mtls_header_sl):
    rvalue = None
    header_value = first_in_list(stringlist_to_list(mtls_header_sl))
    if header_value is not None:
        parsed_url = urlparse(header_value)
        rvalue = parsed_url.path.strip("/")
    return rvalue


class MTLSRemoteUserMiddleware(RemoteUserMiddleware):

    header = settings.MTLS_HEADER

    def process_request(self, request):
        # AuthenticationMiddleware is required so that request.user exists.
        if not hasattr(request, 'user'):
            raise ImproperlyConfigured(
                "The Django remote user auth middleware requires the"
                " authentication middleware to be installed.  Edit your"
                " MIDDLEWARE setting to insert"
                " 'django.contrib.auth.middleware.AuthenticationMiddleware'"
                " before the RemoteUserMiddleware class.")
        try:
            ## THIS PART WE CHANGED
            username = parse_mtls_header(request.META[self.header])
            # END THIS PART WE CHANGED
        except KeyError:
            # If specified header doesn't exist then remove any existing
            # authenticated remote-user, or return (leaving request.user set to
            # AnonymousUser by the AuthenticationMiddleware).
            if self.force_logout_if_no_header and request.user.is_authenticated:
                self._remove_invalid_user(request)
            return
        # If the user is already authenticated and that user is the user we are
        # getting passed in the headers, then the correct user is already
        # persisted in the session and we don't need to continue.
        if request.user.is_authenticated:
            if request.user.get_username() == self.clean_username(username, request):
                return
            else:
                # An authenticated user is associated with the request, but
                # it does not match the authorized user in the header.
                self._remove_invalid_user(request)

        # We are seeing this user for the first time in this session, attempt
        # to authenticate the user.
        user = auth.authenticate(request, remote_user=username)
        if user:
            # User is valid.  Set request.user and persist user in the session
            # by logging the user in.
            request.user = user
            auth.login(request, user)


class MTLSBackend(RemoteUserBackend):
    """
    Authenticate against the mTLS header.
    """
    def authenticate(self, request=None, **credentials):
        return super().authenticate(request, **credentials)