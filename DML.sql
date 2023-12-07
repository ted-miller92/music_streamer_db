/* 
Queries that are to be commonly used in
the implementation of the website and querying of the database.
Dynamically generated variables denoted by ${variableName}
*/

USE music_streamer;

/* Artists
The following are queries to be used for basic CRUD operations
on the Artists table. 
*/

-- Fetch Artists, 
SELECT * FROM Artists;

-- Fetch artist by id
SELECT * FROM Artists 
WHERE artist_id = ${data.artistID};

-- Search for an Artist by name
SELECT * FROM Artists 
WHERE artist_name = "${data.artistName}"
ORDER BY Artists.artist_name ASC;

-- Create an artist
INSERT INTO Artists(artist_name, artist_description)
VALUES(${artistName}, ${artistDescription})

-- Update artist info
UPDATE Artists
SET artist_name = "${artistName}"
WHERE artist_id = ${artist_id};

UPDATE Artists
SET artist_description = ${artist_description}
WHERE artist_id = ${artist_id};

-- Delete an artist
DELETE FROM Artists
WHERE artist_id = ${artist_id};

/* Genres
The following are queries to be used for basic CRUD operations
on the Genres table. 
*/

-- Fetch Genres
SELECT * FROM Genres;

SELECT genre_id FROM Genres WHERE genre_name = "${genreName}";

-- Create Genres
INSERT INTO Genres(genre_name)
VALUES(${genreName});

-- Update Genres
UPDATE Genres
SET genre_name = "${genreName}"
WHERE genre_id =${genreID};

-- Delete Genres
DELETE FROM Genres
WHERE genre_id =${genreID};

/* Playlists
The following are queries to be used for basic CRUD operations
on the Playlists table. 
*/

-- Fetch playlists
SELECT * FROM Playlists;

SELECT * FROM Playlists
WHERE playlist.user_id = ${userID};

-- Create a new playlist
INSERT INTO Playlists(playlist_name, user_id)
VALUES(${playlistName}, ${userID});

-- Update a playlist
UPDATE Playlists 
SET playlist_name = "${playlistName}",
user_id = "${userID}",
private = ${isPrivate}
WHERE playlist_id = ${playlistID};

-- Delete a playlist
DELETE FROM Playlists
WHERE playlist_id = ${playlistID};

/* Playlist_Songs
The following are queries to be used for basic CRUD operations
on the Playlist_Songs table. 
*/

-- Fetch Playlist_Songs of a given Playlist
SELECT song_id FROM Playlist_Songs
WHERE Playlist_Songs.playlist_id = ${playlistID};

-- Create a new Playlist_Songs record 
-- That is, add a song to playlist
INSERT INTO Playlist_Songs(playlist_id, song_id)
VALUES(${playlistID}, ${songID});

-- Update a Playlist_Songs record
-- Unlikely to be necessary, as the more likely
-- work flow will be to remove a song and add a new one
UPDATE Playlist_Songs
SET playlist_id = ${playlistID}
WHERE playlist_song_id = ${playlistSongID};

-- Delete a Playlist_Songs record
-- That is, remove a song from a Playlist
DELETE FROM Playlist_Songs
WHERE playlist_id = ${playlistID}
AND song_id = ${songID};

/* Releases
The following are queries to be used for basic CRUD operations
on the Releases table. 
*/

-- Fetch releases of a given artist
SELECT * FROM Releases
INNER JOIN Release_Types 
ON Releases.release_type_id = Release_Types.release_type_id
WHERE artist_id = ${data.artistID};

-- Fetch releases and associated data, sort by artist name
SELECT Releases.release_id, Releases.release_name, 
Artists.artist_id, Artists.artist_name,
Release_Types.release_type_id, Release_Types.release_type_name 
FROM Releases
INNER JOIN Artists ON Releases.artist_id = Artists.artist_id
INNER JOIN Release_Types ON Releases.release_type_id = Release_Types.release_type_id
ORDER BY Artists.artist_name ASC;

-- Create a new release
INSERT INTO Releases(release_name, release_type_id, artist_id)
VALUES("${releaseName}", ${releaseTypeID}, ${artistID});

-- Update a release
UPDATE Releases 
SET releaseName = "${releaseName}",
artist_id = "${artistID}",
release_type_id = ${releaseTypeID}
WHERE release_id = ${releaseID};

-- Delete a release
DELETE FROM Releases
WHERE release_id = ${releaseID};

/* Release_Types
The following are queries to be used for basic CRUD operations
on the Release_Types table. 
*/

-- Fetch release types
SELECT * FROM Release_Types;

-- Fetch a single release type
SELECT * FROM Release_Types
WHERE release_type_id = ${data.releaseTypeID};

-- Create a new Release_Type
INSERT INTO Release_Types(release_type_name)
VALUES("${releaseTypeName}");

-- Update a Release_Type
UPDATE Release_Types
SET release_type_name = "${releaseTypeName}"
WHERE release_type_id = ${releaseTypeID};

-- Delete a Release_Type
DELETE FROM Release_Types
WHERE release_type_id = ${releaseTypeID};

/* Songs
The following are queries to be used for basic CRUD operations
on the Songs table. 
*/

-- Fetch all songs from a Release
SELECT * FROM Songs
WHERE release_id = ${releaseID};

-- Fetch all songs and join with descriptive data of Releases, Artists, Genres
SELECT * FROM Songs
INNER JOIN Song_Artists ON Songs.song_id = Song_Artists.song_id
INNER JOIN Artists ON Song_Artists.artist_id = Artists.artist_id
INNER JOIN Releases ON Songs.release_id = Releases.release_id
INNER JOIN Genres ON Songs.genre_id = Genres.genre_id;

-- Search for a song
SELECT * FROM Songs
INNER JOIN Song_Artists ON Songs.song_id = Song_Artists.song_id
INNER JOIN Artists ON Song_Artists.artist_id = Artists.artist_id
INNER JOIN Releases ON Songs.release_id = Releases.release_id
INNER JOIN Genres ON Songs.genre_id = Genres.genre_id
WHERE Songs.song_name LIKE '%${data.searchSong}%';

-- Fetch all songs from an Artist
SELECT * FROM Songs 
INNER JOIN Song_Artists ON Songs.song_id = Song_Artists.song_id
INNER JOIN Artists ON Song_Artists.artist_id = Artists.artist_id
INNER JOIN Releases ON Songs.release_id = Releases.release_id
INNER JOIN Genres ON Songs.genre_id = Genres.genre_id
WHERE Song_Artists.artist_id = ${data.artistID};

-- Create a new song
INSERT INTO Songs(song_name, release_id, genre_id, stream_count)
VALUES("${songName}", ${releaseID}, ${genreID}, 0);

-- Update a song
UPDATE Songs 
SET song_name = "${songName}",
release_id = "${releaseID}",
genre_id = ${genreID},
stream_count = ${streamCount}
WHERE song_id = ${songID};

-- Delete a song
DELETE FROM Songs
WHERE song_id = ${songID};

/* Song_Artists
The following are queries to be used for basic CRUD operations
on the Song_Artists table. Basically, this will be attributing one or more
artists to any given song
*/

-- Select all songs from a given artist
SELECT * FROM Song_Artists
WHERE Song_Artists.artist_id = ${artistID};

-- Select the artist(s) of a song
SELECT artist_id FROM Song_Artists
WHERE Song_Artists.song_id = ${songID};

-- Insert into Song_Artists
-- basically, attribute a song to an artist
INSERT INTO Song_Artists(song_id, artist_id)
VALUES (${songID}, ${artistID});

-- Delete from Song_Artists
DELETE FROM Song_Artists
WHERE song_artists_id = ${songArtistsID};

/* Users
The following are queries to be used for basic CRUD operations
on the Users table. 
*/

-- Select all users
SELECT * FROM Users;

-- Select a specific user
SELECT * FROM Users
WHERE Users.user_email = "${userEmail}";

-- Add a new user
INSERT INTO Users(user_name, user_email)
VALUES("${userName}", "${user_email}");

-- Update a user's email
UPDATE USERS
SET user_email = ${userEmail}
WHERE user_id = ${userID};

-- Update a user's username
UPDATE USERS
SET user_name = ${userName}
WHERE user_id = ${userID};

-- Delete a user
DELETE FROM Users
WHERE user_id = ${userID};
