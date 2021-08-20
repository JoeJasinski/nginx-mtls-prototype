FROM python:3.9
ENV PATH=$PATH:/src/.local/bin
ENV PYTHONPATH=$PYTHONPATH:/src/mtls_django
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV DJANGO_SETTINGS_MODULE=mtls_django.settings
RUN useradd app -m --home-dir /src/

USER app
WORKDIR /src/

COPY requirements.txt requirements.txt

RUN pip install --user -r requirements.txt

COPY --chown=app:app ./ /src/mtls_django/

ENTRYPOINT ["/src/mtls_django/entrypoint.sh"]
CMD ["/src/mtls_django/run.sh"]