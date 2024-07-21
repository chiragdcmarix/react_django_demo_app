# Backend (Django)
FROM python:3.13.0b3-slim as backend

WORKDIR /app

COPY backend/requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

COPY backend /app/
RUN python manage.py collectstatic --noinput

# Frontend (React)
FROM node:14 as frontend

WORKDIR /app

COPY frontend/package.json /app/
COPY frontend/package-lock.json /app/
RUN npm install

COPY frontend /app/
RUN npm run build

# Final Image
FROM python:3.13.0b3-slim

WORKDIR /app

COPY --from=backend /app /app/backend
COPY --from=frontend /app/build /app/frontend/build

WORKDIR /app/backend

EXPOSE 8002
CMD ["gunicorn", "--bind", "0.0.0.0:8002", "backend.wsgi:application"]
