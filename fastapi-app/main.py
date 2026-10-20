from fastapi import FastAPI

# Create the application instance
app = FastAPI()

# Define a root route
@app.get("/")
def read_root():
    return {"message": "Hello, FastAPI!"}
