-- Authors: Ted Miller, Chris Garrett
-- Date: 12/6/2023

USE music_streamer;

-- Drop tables before creating new ones
DROP TABLE IF EXISTS Users, Artists, Release_Types, Genres, Releases, Songs, Song_Artists, Playlists, Playlist_Songs;

-- Users table
CREATE TABLE Users(
	user_id INT NOT NULL UNIQUE AUTO_INCREMENT,
    user_name VARCHAR(255),
    user_email VARCHAR(255),
    PRIMARY KEY (user_id)
);

-- Artists table
CREATE TABLE Artists(
	artist_id INT NOT NULL UNIQUE AUTO_INCREMENT,
    artist_name VARCHAR(255) NOT NULL,
    artist_description MEDIUMTEXT,
    PRIMARY KEY (artist_id)
);

-- Release_Types table (album, extended-play, single, etc.)
CREATE TABLE Release_Types(
	release_type_id INT NOT NULL UNIQUE AUTO_INCREMENT,
    release_type_name VARCHAR(255) NOT NULL,
    PRIMARY KEY (release_type_id)
);

-- Genres table
CREATE TABLE Genres(
	genre_id INT NOT NULL UNIQUE AUTO_INCREMENT,
    genre_name VARCHAR(255) NOT NULL,
    PRIMARY KEY (genre_id)
);

-- Releases table
-- References Release_Types to identify release as an album, ep, single, etc.
-- References Artists to identify who published/released the album, ep, etc.
CREATE TABLE Releases(
	release_id INT NOT NULL UNIQUE AUTO_INCREMENT,
    release_name VARCHAR(255) NOT NULL,
    release_type_id INT,
    artist_id INT NOT NULL,
    PRIMARY KEY (release_id),
    FOREIGN KEY (release_type_id) REFERENCES Release_Types(release_type_id) 
		ON DELETE SET NULL	-- When a Release_Type is deleted, this field will be set to Null
        ON UPDATE CASCADE,	-- When a Release_Type is updated, this will cascade to be reflected in this table
    FOREIGN KEY (artist_id) REFERENCES Artists(artist_id) 
		ON DELETE CASCADE	-- When an Artist is deleted, all of their Releases will also be deleted
        ON UPDATE CASCADE	-- When an Artist is updated, all of their Releases will also be updated
);

-- Songs table
-- References Releases to attribute it to a specific release
-- References Genres to classify it as a certain genre
CREATE TABLE Songs(
	song_id INT NOT NULL UNIQUE AUTO_INCREMENT,
    song_name VARCHAR(255) NOT NULL,
    release_id INT NOT NULL,
    genre_id INT NULL,
    stream_count INT NOT NULL,
    PRIMARY KEY (song_id),
    FOREIGN KEY (release_id) REFERENCES Releases(release_id) 
		ON DELETE CASCADE,	-- When a Release is deleted, the associated songs will be deleted
    FOREIGN KEY (genre_id) REFERENCES Genres(genre_id) 
		ON DELETE SET NULL	-- When a genre is deleted, this field will be set to Null
);

-- Song_Artists table. This is an intersection table that
-- keeps track of the Artist(s) attributed to a song
CREATE TABLE Song_Artists(
	song_artists_id INT NOT NULL UNIQUE AUTO_INCREMENT,
    song_id INT NOT NULL,
    artist_id INT NOT NULL,
    PRIMARY KEY (song_artists_id),
    FOREIGN KEY (song_id) REFERENCES Songs(song_id) 
		ON DELETE CASCADE,	-- When a Song is deleted, the Song_Artist record will also be deleted
    FOREIGN KEY (artist_id) REFERENCES Artists(artist_id) 
		ON DELETE CASCADE	-- When an Artist is deleted, the Song_Artist record will also be deleted
);

-- Playlists table
CREATE TABLE Playlists(
	playlist_id INT NOT NULL UNIQUE AUTO_INCREMENT,
    user_id INT NOT NULL,
    playlist_name VARCHAR(255) NOT NULL,
    private TINYINT(1) DEFAULT 1 NOT NULL,
    PRIMARY KEY (playlist_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) 
		ON DELETE CASCADE	-- When a User is deleted, their playlists will also be deleted
);

-- Playlist_Songs table. Intersection table that tracks
-- the songs that are on a playlist
CREATE TABLE Playlist_Songs(
	playlist_song_id INT NOT NULL UNIQUE AUTO_INCREMENT,
    playlist_id INT NOT NULL,
    song_id INT NOT NULL,
    PRIMARY KEY (playlist_song_id),
    FOREIGN KEY (playlist_id) REFERENCES Playlists(playlist_id) 
		ON DELETE CASCADE,	-- When a Playlist is deleted, all records associated in this table will be deleted
    FOREIGN KEY (song_id) REFERENCES Songs(song_id)
		ON DELETE CASCADE	-- When a Song is deleted, all records associated in this table will be deleted
);

-- The following is a trigger definition for creating new Song_Artist 
-- records when a new song is added
DROP TRIGGER IF EXISTS `cs340_millert8`.`Songs_AFTER_INSERT`;

DELIMITER $$
USE `cs340_millert8`$$
CREATE TRIGGER `Songs_AFTER_INSERT` AFTER INSERT ON `Songs` FOR EACH ROW BEGIN
	INSERT INTO Song_Artists(song_id, artist_id)
    VALUES(NEW.song_id, (
		SELECT Releases.artist_id FROM Releases 
        WHERE Releases.release_id = NEW.release_id
    ));
END$$
DELIMITER ;

-- The following queries are for data insertion

INSERT INTO Genres(genre_name) 
VALUES ("Rock"), ("Alternative Rock"), ("Pop"), ("Electronic"), ("Country");

INSERT INTO Release_Types(release_type_name) 
VALUES ("Single"), ("Album"), ("EP"), ("Collaboration");

INSERT INTO Artists(artist_name, artist_description) 
VALUES 
	("Linkin Park", "Band Members: Chester Bennington, Mike Shinoda, Brad Delson, Dave Farrell, Joe Hahn, Rob Bourdon"),
	("Red Hot Chili Peppers", "Band Members: Anthony Kiedis, Chad Smith, Michael Balzary, John Frusciante"),
	("Queen", "Band Members: Freddie Mercury, Brian May, Roger Taylor, John Deacon");

INSERT INTO Releases(release_name, release_type_id, artist_id) 
VALUES 
	("Meteora", (SELECT release_type_id FROM Release_Types WHERE release_type_name = "Album"), (SELECT artist_id FROM Artists WHERE artist_name = "Linkin Park")),
	("By The Way", (SELECT release_type_id FROM Release_Types WHERE release_type_name = "Album"), (SELECT artist_id FROM Artists WHERE artist_name = "Red Hot Chili Peppers")),
	("A Night at the Opera", (SELECT release_type_id FROM Release_Types WHERE release_type_name = "Album"), (SELECT artist_id FROM Artists WHERE artist_name = "Queen"));

INSERT INTO Songs(song_name, release_id, genre_id, stream_count)
VALUES
	("Breaking the Habit", (SELECT release_id FROM Releases WHERE release_name = "Meteora"), (SELECT genre_id FROM Genres WHERE genre_name = "Alternative Rock"), 0),
	("Can't Stop", (SELECT release_id FROM Releases WHERE release_name = "By The Way"), (SELECT genre_id FROM Genres WHERE genre_name = "Alternative Rock"), 0),
	("By The Way", (SELECT release_id FROM Releases WHERE release_name = "By The Way"), (SELECT genre_id FROM Genres WHERE genre_name = "Alternative Rock"), 0),
	("Bohemian Rhapsody", (SELECT release_id FROM Releases WHERE release_name = "A Night at the Opera"), (SELECT genre_id FROM Genres WHERE genre_name = "Rock"), 0),
	("Somewhere I Belong", (SELECT release_id FROM Releases WHERE release_name = "Meteora"), (SELECT genre_id FROM Genres WHERE genre_name = "Alternative Rock"), 0);

INSERT INTO Users (user_name, user_email)
VALUES 
	("Ted Miller", "millert8@oregonstate.edu"), 
    ("Chris Garrett", "garrchri@oregonstate.edu"), 
    ("John Smith", "JohnSmith@fakeuser.com");

INSERT INTO Playlists(playlist_name, user_id)
VALUES
	("playlist 1", (SELECT user_id FROM Users WHERE user_name = "Ted Miller")),
	("playlist 2", (SELECT user_id FROM Users WHERE user_name = "Chris Garrett")),
	("playlist 3", (SELECT user_id FROM Users WHERE user_name = "John Smith"));

INSERT INTO Playlist_Songs(playlist_id, song_id)
VALUES
	((SELECT playlist_id FROM Playlists WHERE playlist_name = "playlist 1"), (SELECT song_id FROM Songs WHERE song_name = "Breaking the Habit")),
	((SELECT playlist_id FROM Playlists WHERE playlist_name = "playlist 1"), (SELECT song_id FROM Songs WHERE song_name = "Can't Stop")),
	((SELECT playlist_id FROM Playlists WHERE playlist_name = "playlist 2"), (SELECT song_id FROM Songs WHERE song_name = "Somewhere I Belong")),
	((SELECT playlist_id FROM Playlists WHERE playlist_name = "playlist 2"), (SELECT song_id FROM Songs WHERE song_name = "Bohemian Rhapsody")),
	((SELECT playlist_id FROM Playlists WHERE playlist_name = "playlist 3"), (SELECT song_id FROM Songs WHERE song_name = "Breaking the Habit")),
	((SELECT playlist_id FROM Playlists WHERE playlist_name = "playlist 3"), (SELECT song_id FROM Songs WHERE song_name = "By The Way"));
