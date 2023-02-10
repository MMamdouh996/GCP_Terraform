FROM python:3.8-alpine
WORKDIR /code

ENV ENVIRONMENT=DEV
ENV HOST=localhost
ENV PORT=8000
ENV REDIS_HOST=localhost
ENV REDIS_PORT=6379
ENV REDIS_DB=0

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

EXPOSE 8000
COPY . .
CMD ["python", "hello.py"]