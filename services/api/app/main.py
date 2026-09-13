import os
import uuid
from datetime import datetime, date, time
from enum import Enum

from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy import (
    create_engine,
    String,
    Text,
    DateTime,
    Date,
    Time,
    Enum as SAEnum,
)
from sqlalchemy.orm import (
    DeclarativeBase,
    Mapped,
    mapped_column,
    sessionmaker,
    Session,
)


# DATABASE

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+psycopg://prayer:prayer@db:5432/prayer"
)

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True
)

SessionLocal = sessionmaker(bind=engine)


# BASE

class Base(DeclarativeBase):
    pass


# ENUMS

class Role(str, Enum):
    CUSTOMER = "CUSTOMER"
    VENDOR = "VENDOR"
    RIDER = "RIDER"
    PRAYER_TEAM = "PRAYER_TEAM"
    ADMIN = "ADMIN"
    SUPER_ADMIN = "SUPER_ADMIN"


class PrayerStatus(str, Enum):
    PENDING = "PENDING"
    ASSIGNED = "ASSIGNED"
    ACCEPTED = "ACCEPTED"
    SCHEDULED = "SCHEDULED"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"


# USER MODEL

class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(
        String,
        primary_key=True,
        default=lambda: str(uuid.uuid4())
    )

    name: Mapped[str] = mapped_column(String(120))

    mobile: Mapped[str] = mapped_column(
        String(30),
        unique=True
    )

    email: Mapped[str | None] = mapped_column(
        String(255),
        nullable=True
    )

    role: Mapped[Role] = mapped_column(
        SAEnum(Role),
        default=Role.CUSTOMER
    )


# VIDEO PRAYER SESSION MODEL

class VideoPrayerSession(Base):
    __tablename__ = "video_prayer_sessions"

    id: Mapped[str] = mapped_column(
        String,
        primary_key=True,
        default=lambda: str(uuid.uuid4())
    )

    booking_id: Mapped[str] = mapped_column(
        String(40),
        unique=True,
        index=True
    )

    customer_name: Mapped[str] = mapped_column(
        String(120)
    )

    mobile: Mapped[str] = mapped_column(
        String(30)
    )

    email: Mapped[str | None] = mapped_column(
        String(255),
        nullable=True
    )

    language: Mapped[str] = mapped_column(
        String(60)
    )

    category: Mapped[str] = mapped_column(
        String(120)
    )

    session_type: Mapped[str] = mapped_column(
        String(30)
    )

    preferred_date: Mapped[date] = mapped_column(
        Date
    )

    preferred_time: Mapped[time] = mapped_column(
        Time
    )

    duration_minutes: Mapped[int] = mapped_column(
        default=30
    )

    prayer_request: Mapped[str] = mapped_column(
        Text
    )

    notes: Mapped[str | None] = mapped_column(
        Text,
        nullable=True
    )

    status: Mapped[PrayerStatus] = mapped_column(
        SAEnum(PrayerStatus),
        default=PrayerStatus.PENDING
    )

    minister_id: Mapped[str | None] = mapped_column(
        String,
        nullable=True
    )

    secure_room_id: Mapped[str | None] = mapped_column(
        String,
        nullable=True
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow
    )


# CREATE DATABASE TABLES

Base.metadata.create_all(engine)


# FASTAPI APP

app = FastAPI(
    title="Christian Prayer Platform API",
    version="1.0.0"
)


# ROOT ROUTE

@app.get("/")
def root():
    return {
        "message": "Christian Prayer Platform API is running!",
        "docs": "/docs",
        "health": "/health"
    }


# DATABASE DEPENDENCY

def db():
    s = SessionLocal()

    try:
        yield s

    finally:
        s.close()


# REQUEST MODEL

class VideoBookingIn(BaseModel):
    name: str
    mobile: str
    email: str | None = None
    language: str
    category: str
    preferred_date: date
    preferred_time: time
    duration_minutes: int = 30
    session_type: str
    prayer_request: str
    additional_notes: str | None = None


# BOOKING NUMBER

def booking_number():
    return f"VP-{datetime.utcnow().year}-{uuid.uuid4().hex[:8].upper()}"


# HEALTH CHECK

@app.get("/health")
def health():
    return {
        "ok": True,
        "service": "christian-prayer-platform-api"
    }


# CREATE VIDEO PRAYER BOOKING

@app.post("/api/video-prayer/bookings")
def create_booking(
    data: VideoBookingIn,
    s: Session = Depends(db)
):

    obj = VideoPrayerSession(

        booking_id=booking_number(),

        customer_name=data.name,

        mobile=data.mobile,

        email=data.email,

        language=data.language,

        category=data.category,

        preferred_date=data.preferred_date,

        preferred_time=data.preferred_time,

        duration_minutes=data.duration_minutes,

        session_type=data.session_type,

        prayer_request=data.prayer_request,

        notes=data.additional_notes
    )

    s.add(obj)

    s.commit()

    s.refresh(obj)

    return {
        "id": obj.id,
        "booking_id": obj.booking_id,
        "status": obj.status
    }


# LIST BOOKINGS

@app.get("/api/video-prayer/bookings")
def list_bookings(
    s: Session = Depends(db)
):

    rows = (
        s.query(VideoPrayerSession)
        .order_by(VideoPrayerSession.created_at.desc())
        .all()
    )

    return [

        {
            "id": x.id,

            "booking_id": x.booking_id,

            "customer": x.customer_name,

            "date": str(x.preferred_date),

            "time": str(x.preferred_time),

            "category": x.category,

            "status": x.status
        }

        for x in rows
    ]


# ASSIGN MINISTER

@app.post(
    "/api/video-prayer/bookings/{booking_id}/assign/{minister_id}"
)

def assign(
    booking_id: str,
    minister_id: str,
    s: Session = Depends(db)
):

    x = (
        s.query(VideoPrayerSession)
        .filter_by(booking_id=booking_id)
        .first()
    )

    if not x:
        raise HTTPException(
            status_code=404,
            detail="Booking not found"
        )

    conflict = (
        s.query(VideoPrayerSession)
        .filter(

            VideoPrayerSession.minister_id == minister_id,

            VideoPrayerSession.preferred_date == x.preferred_date,

            VideoPrayerSession.preferred_time == x.preferred_time,

            VideoPrayerSession.status.in_([
                PrayerStatus.ASSIGNED,
                PrayerStatus.ACCEPTED,
                PrayerStatus.SCHEDULED
            ])

        )
        .first()
    )

    if conflict:

        raise HTTPException(
            status_code=409,
            detail="Minister already has a session at this time"
        )

    x.minister_id = minister_id

    x.status = PrayerStatus.ASSIGNED

    x.secure_room_id = f"vp-{uuid.uuid4().hex}"

    s.commit()

    return {
        "booking_id": x.booking_id,

        "status": x.status,

        "secure_room_created": True
    }


# JOIN SESSION

@app.post(
    "/api/video-prayer/bookings/{booking_id}/join"
)

def join(
    booking_id: str,
    s: Session = Depends(db)
):

    x = (
        s.query(VideoPrayerSession)
        .filter_by(booking_id=booking_id)
        .first()
    )

    if not x or not x.secure_room_id:

        raise HTTPException(
            status_code=403,
            detail="Session is not ready"
        )

    return {

        "room_id": x.secure_room_id,

        "message": "Provider-specific short-lived video token must be generated server-side"

    }


# ADMIN DASHBOARD

@app.get("/api/admin/dashboard")
def dashboard(
    s: Session = Depends(db)
):

    rows = s.query(VideoPrayerSession).all()

    return {

        "todays_sessions":

            sum(
                1
                for x in rows
                if x.preferred_date == date.today()
            ),

        "upcoming_sessions":

            sum(
                1
                for x in rows
                if x.status in [
                    PrayerStatus.PENDING,
                    PrayerStatus.ASSIGNED,
                    PrayerStatus.SCHEDULED
                ]
            ),

        "completed_sessions":

            sum(
                1
                for x in rows
                if x.status == PrayerStatus.COMPLETED
            ),

        "cancelled_sessions":

            sum(
                1
                for x in rows
                if x.status == PrayerStatus.CANCELLED
            ),

        "pending_assignments":

            sum(
                1
                for x in rows
                if x.status == PrayerStatus.PENDING
            )
    }
