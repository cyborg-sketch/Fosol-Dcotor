from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str = "postgresql+psycopg2://fasol:fasol@localhost:5432/fasol_doctor"
    confidence_auto_threshold: float = 0.75
    vision_model_api_key: str = ""
    stt_api_key: str = ""
    llm_api_key: str = ""

    class Config:
        env_file = ".env"


settings = Settings()
