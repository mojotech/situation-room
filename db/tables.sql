DROP TABLE Site;

CREATE TABLE Site (
    ID SERIAL PRIMARY KEY,
    Endpoint varchar(255) UNIQUE NOT NULL,
    Name varchar(255) NOT NULL,
    Created_at BIGINT NOT NULL DEFAULT extract(epoch from now())
);

DROP TABLE Active;

CREATE TABLE Active (
    SID SERIAL,
    Is_Active boolean NOT NULL DEFAULT false,
    FOREIGN KEY (SID) REFERENCES Site(ID)
);

DROP TABLE Ping_History;

CREATE TABLE Ping_History (
    ID SERIAL PRIMARY KEY,
    SID int NOT NULL,
    Timestamp BIGINT NOT NULL DEFAULT extract(epoch from now()),
    Result boolean NOT NULL,
    Latency int,
    FOREIGN KEY (SID) REFERENCES Site(ID)
);