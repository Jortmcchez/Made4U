-- SIGNUP PAGE
-- Insert Query:
INSERT INTO new_users (email, username, password, role, first_name, last_name)
VALUES ('%s', '%s', '%s', 'Artist', '%s', '%s');
-- Check for Existing Email or Username

-- Check if the email already exists
SELECT user_id
FROM new_users
WHERE email = '%s';

-- Check if the username already exists
SELECT user_id
FROM new_users
WHERE username = '%s';

--LOGIN PAGE
-- Query to validate user login with role
SELECT user_id, role
FROM new_users
WHERE email = %s
  AND password = %s
  AND role = %s;

-- Query to check if the email exists
SELECT user_id
FROM new_users
WHERE email = %s;

-- Check if the role matches the given email
SELECT user_id
FROM new_users
WHERE email = %s AND role = %s;



-- Artist Directory Page:
-- Retrieve all artists with their average rating
SELECT nu.user_id, 
       nu.username, 
       nu.first_name, 
       nu.last_name,
       COALESCE(AVG(r.rating), 0) AS average_rating
FROM new_users nu
LEFT JOIN ratings r ON nu.user_id = r.artist_id
WHERE nu.role = 'Artist'
GROUP BY nu.user_id, nu.username, nu.first_name, nu.last_name;

-- Search for artists by name with average rating 
SELECT nu.user_id, 
       nu.username, 
       nu.first_name, 
       nu.last_name,
       COALESCE(AVG(r.rating), 0) AS average_rating
FROM new_users nu
LEFT JOIN ratings r ON nu.user_id = r.artist_id
WHERE nu.role = 'Artist'
  AND (LOWER(nu.first_name) LIKE LOWER(%s) OR LOWER(nu.last_name) LIKE LOWER(%s))
GROUP BY nu.user_id, nu.username, nu.first_name, nu.last_name;

-- Search for artists by username with average rating 
SELECT nu.user_id, 
       nu.username, 
       nu.first_name, 
       nu.last_name,
       COALESCE(AVG(r.rating), 0) AS average_rating
FROM new_users nu
LEFT JOIN ratings r ON nu.user_id = r.artist_id
WHERE nu.role = 'Artist'
  AND LOWER(nu.username) LIKE LOWER(%s)
GROUP BY nu.user_id, nu.username, nu.first_name, nu.last_name;



--Artist Portfolio Page
-- artist details with their average rating
SELECT nu.user_id, 
       nu.username, 
       nu.first_name, 
       nu.last_name,
       COALESCE(AVG(r.rating), 0) AS average_rating
FROM new_users nu
LEFT JOIN ratings r ON nu.user_id = r.artist_id
WHERE nu.user_id = %s --artist's user_id
GROUP BY nu.user_id, nu.username, nu.first_name, nu.last_name;

-- all artworks in the artist's portfolio
SELECT a.artwork_id, 
       a.title, 
       a.image_url, 
       a.cost
FROM artworks a
JOIN portfolios p ON a.artwork_id = p.art_id
WHERE p.artist_id = %s; --artist's user_id



--Request Art Page
-- Check if the commissioner exists
SELECT user_id, password, username
FROM new_users
WHERE email = %s AND role = 'Commissioner';

--Verify Password(BACKEND)
	--If password matches: Proceed to the next step.
	--If it doesn’t match: Show an error like “Invalid password.”
	
-- Update the username if it is different
UPDATE new_users
SET username = %s
WHERE user_id = %s AND username != %s;

-- Create a new commissioner if they don't exist
INSERT INTO new_users (email, username, password, role)
VALUES (%s, %s, %s, 'Commissioner')
RETURNING user_id;

-- Insert a new commission request
INSERT INTO commissions (commissioner_id, artist_id, title, description, deadline)
VALUES (%s, %s, %s, %s, %s)
RETURNING commission_id;



--ARTIST DASHBOARD
	--SAME QUESRIES AS ARTIST PORTFOLIO

-- Add a new portfolio item
INSERT INTO artworks (title, image_url, cost)
VALUES (%s, %s, %s)
RETURNING artwork_id;

INSERT INTO portfolios (artist_id, art_id)
VALUES (%s, %s);

-- Delete a portfolio item
DELETE FROM portfolios
WHERE artist_id = %s AND art_id = %s;
	-- We dont delete the artwok because they can be seen in commionser or artist completed work.



-- VIEW REQUESTS PAGE
--pending commission requests
SELECT c.commission_id, 
       c.title, 
       c.description, 
       c.deadline, 
       nu.username AS commissioner_username
FROM commissions c
JOIN new_users nu ON c.commissioner_id = nu.user_id
WHERE c.artist_id = %s AND c.status = 'Pending';

--ongoing commission requests
SELECT c.commission_id, 
       c.title, 
       c.description, 
       c.deadline, 
       nu.username AS commissioner_username
FROM commissions c
JOIN new_users nu ON c.commissioner_id = nu.user_id
WHERE c.artist_id = %s AND c.status = 'Ongoing';

--completed commission requests
SELECT 
    c.commission_id,
    c.title AS commission_title,
    c.description AS commission_description,
    c.deadline AS completion_deadline,
    cc.status AS completion_status,
    cc.final_artwork_url AS final_artwork
FROM completed_commissions cc
JOIN commissions c ON cc.commission_id = c.commission_id
WHERE c.artist_id = %s;

-- Accept a commission
UPDATE commissions
SET status = 'Ongoing'
WHERE commission_id = %s AND artist_id = %s;

-- Reject a commission
UPDATE commissions
SET status = 'Rejected'
WHERE commission_id = %s AND artist_id = %s;

-- Upload Artwork
INSERT INTO completed_commissions (commission_id, final_artwork_url)
VALUES (%s, %s)
RETURNING completed_id;

-- Update the commission status to 'Completed'
UPDATE commissions
SET status = 'Completed'
WHERE commission_id = %s AND artist_id = %s;

--FUNCTION to populate_completed_commissions()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert into completed_commissions when status changes to 'Completed'
    IF NEW.status = 'Completed' THEN
        INSERT INTO completed_commissions (commission_id, final_artwork_url, status)
        VALUES (
            NEW.commission_id,
            NULL,                 -- Final artwork URL is initially NULL
            'In Review'           -- Initial status is 'In Review'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
 -- TRIGER FUNCTION for the same
CREATE TRIGGER trigger_populate_completed_commissions
AFTER UPDATE OF status
ON commissions
FOR EACH ROW
WHEN (NEW.status = 'Completed')
EXECUTE FUNCTION populate_completed_commissions();


--COMMISIONER DASHBOARD
-- GEt pending requests for the commissioner
SELECT c.commission_id, 
       c.title, 
       c.description, 
       c.deadline, 
       nu.username AS artist_username
FROM commissions c
JOIN new_users nu ON c.artist_id = nu.user_id
WHERE c.commissioner_id = %s AND c.status = 'Pending';

-- Get ongoing requests for the commissioner
SELECT c.commission_id, 
       c.title, 
       c.description, 
       c.deadline, 
       nu.username AS artist_username
FROM commissions c
JOIN new_users nu ON c.artist_id = nu.user_id
WHERE c.commissioner_id = %s AND c.status = 'Ongoing';

-- Get completed requests for the commissioner
SELECT 
    c.commission_id,
    c.title AS commission_title,
    c.description AS commission_description,
    c.deadline AS completion_deadline,
    cc.status AS completion_status,
    cc.final_artwork_url AS final_artwork
FROM completed_commissions cc
JOIN commissions c ON cc.commission_id = c.commission_id
WHERE c.commissioner_id = <commissioner_id>;

-- Approve completed commission
UPDATE completed_commissions
SET status = 'Approved'
WHERE completed_id = %s;


-- Cancel a pending commission request
UPDATE commissions
SET status = 'Cancelled'
WHERE commission_id = %s AND commissioner_id = %s AND status = 'Pending';

-- Raise dispute for completed commission
INSERT INTO disputes (completed_id, description, status)
VALUES (%s, %s, 'Open')
RETURNING dispute_id;
	--Update the status of the completed commission to Disputed
	UPDATE completed_commissions
	SET status = 'Disputed'
	WHERE completed_id = <completed_id>;

-- Add a rating and review for an artist
INSERT INTO ratings (completed_id, commissioner_id, artist_id, rating)
VALUES (%s, %s, %s, %s);

-- Populate disputed table automatically with completed commissions that status is changed to disputed:
CREATE FUNCTION handle_disputed_commissions()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'Disputed' THEN
        INSERT INTO disputes (completed_id, description, status)
        VALUES (
            NEW.completed_id,
            'A dispute has been raised for this commission.',
            'Open'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_handle_disputed_commissions
AFTER UPDATE OF status
ON completed_commissions
FOR EACH ROW
WHEN (NEW.status = 'Disputed')
EXECUTE FUNCTION handle_disputed_commissions();

-- Moderator Dashboard
--All moderator action:
SELECT 
    m.moderator_id,
    mod_user.username AS moderator_name,
    m.dispute_id,
    m.banned_user_id,
    m.action_taken,
    m.action_date
FROM moderators m
LEFT JOIN users mod_user ON m.user_id = mod_user.user_id;

--Resolve a dispute
UPDATE disputes
SET status = 'Resolved',
    resolution = %s
WHERE dispute_id = %s;

	--Log it in into moderator table
	INSERT INTO moderators (user_id, dispute_id, action_taken)
	VALUES 
	(%s, %s, %s);
	
--BAN USER
--DELETE FROM users
WHERE user_id = %s;

	--Log the Ban in the moderators Table
	INSERT INTO moderators (user_id, banned_user_id, action_taken)
	VALUES 
	(%s, %s, %s);
