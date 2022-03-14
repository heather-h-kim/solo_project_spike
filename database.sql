create table "cats" (
	"id" SERIAL PRIMARY KEY,
	"name" varchar(100) NOT NULL,
	"age" varchar(100) NOT NULL,
	"is_neutered" boolean,
	"current_weight" numeric,
	"current_weight_date" date DEFAULT CURRENT_DATE,
	"goal_weight" numeric,
	"treat_percentage" int,
	"total_daily_cal" int,
	"adj_daily_cal" int,
	"food_cal" int,
	"treat_cal" int,
	"wet_percentage" int
);

CREATE TABLE "foods" (
	"id" SERIAL PRIMARY KEY,
	"name" varchar(500) NOT NULL,
	"type" varchar(100), 
	"cal_per_unit" int,
	"cal_per_kg" int,
	"daily_amount_unit" numeric,
	"daily_amount_oz" numeric
); 

CREATE TABLE "cats_foods" (
	"id" SERIAL PRIMARY KEY, 
	"cat_id" int REFERENCES "cats",
	"food_id" int REFERENCES "foods"
);



INSERT INTO "cats" ("name", "age", "is_neutered", "current_weight", "goal_weight", "treat_percentage", "wet_percentage")
VALUES ('Pochi Kim', 'adult', true, 8.9, 8.5, 10, 30);


INSERT INTO "foods" ("name", "type", "cal_per_unit", "cal_per_kg")
VALUES ('dryfood', 'dry', 395, 3670), ('wetfood', 'wet', 57, 673);

INSERT INTO "cats_foods" ("cat_id", "food_id")
VALUES (1, 1), (1, 2);

INSERT INTO "cats" ("name", "age", "is_neutered", "current_weight", "goal_weight", "treat_percentage", "wet_percentage", "dry_percentage")
VALUES ('Fluffy', 'adult', false, 12, 9, 5, 100, 0), ('Pepper', 'kitten', false, 5, 3.5, 4, 0, 100);


DROP TABLE "cats_foods";
DROP TABLE "cats";
DROP TABLE "foods";


SELECT 
 CASE WHEN "age" = 'adult' AND "is_neutered" = true THEN 
  (SELECT 70*1.2*0.8*("goal_weight"*0.453592)^0.75 AS calorie FROM "cats" WHERE "id"=1)   
  WHEN "age" = 'adult' AND "is_neutered" = false THEN 
  (SELECT 70*1.4*0.8*("goal_weight"*0.453592)^0.75 AS calorie FROM "cats" WHERE "id"=1)
  WHEN "age" = 'kitten' AND "is_neutered" = true THEN 
  (SELECT 70*1.2*2.5*0.8*("goal_weight"*0.453592)^0.75 AS calorie FROM "cats" WHERE "id"=1)
 WHEN "age" = 'kitten' AND "is_neutered" = false THEN 
  (SELECT 70*1.4*2.5*0.8*("goal_weight"*0.453592)^0.75 AS calorie FROM "cats" WHERE "id"=1)  
  END calorie
 FROM "cats"
 WHERE "id" = 1;

 
SELECT ("treat_percentage"*0.01)*70*1.2*0.8*("goal_weight"*0.453592)^0.75 FROM "cats";
SELECT ((100-"treat_percentage")*0.01)*70*1.2*0.8*("goal_weight"*0.453592)^0.75 FROM "cats";

 
UPDATE "cats"
SET 
"total_daily_cal" =  
	(SELECT  
		CASE WHEN "age" = 'adult' AND "is_neutered" = true THEN (SELECT 70*1.2*0.8*("goal_weight"*0.453592)^0.75)   
 		 	 WHEN "age" = 'adult' AND "is_neutered" = false THEN (SELECT 70*1.4*0.8*("goal_weight"*0.453592)^0.75)
 		 	 WHEN "age" = 'kitten' AND "is_neutered" = true THEN (SELECT 70*1.2*2.5*0.8*("goal_weight"*0.453592)^0.75)
 		 	 WHEN "age" = 'kitten' AND "is_neutered" = false THEN (SELECT 70*1.4*2.5*0.8*("goal_weight"*0.453592)^0.75)  
     	END 
     FROM "cats" WHERE "id"=1), 
"treat_cal" = (SELECT ("treat_percentage"*0.01)*70*1.2*0.8*("goal_weight"*0.453592)^0.75),
"food_cal" = (SELECT ((100-"treat_percentage")*0.01)*70*1.2*0.8*("goal_weight"*0.453592)^0.75)
WHERE "id"=1;
 

SELECT "foods"."name", 
	(CASE WHEN "foods"."type" = 'wet' THEN (SELECT "cats"."food_cal"*"cats"."wet_percentage"*0.01/"foods"."cal_per_unit" FROM "cats" JOIN "cats_foods" ON "cats_foods"."cat_id" = "cats"."id" JOIN "foods" ON "cats_foods"."cat_id" = "foods"."id" WHERE "foods"."id" = 1) 
	 		 WHEN "foods"."type" = 'dry' THEN (SELECT "cats"."food_cal"*(100-"cats"."wet_percentage")*0.01/"foods"."cal_per_unit" FROM "cats" JOIN "cats_foods" ON "cats_foods"."cat_id" = "cats"."id" JOIN "foods" ON "cats_foods"."food_id" = "foods"."id" WHERE "foods"."id" = 1) 	
	 END)
FROM "foods" 
JOIN "cats_foods" 
ON "cats_foods"."food_id" = "foods"."id" 
JOIN "cats" 
ON "cats_foods"."cat_id" = "cats"."id"
WHERE "foods"."id" = 1;


UPDATE "foods"
SET "daily_amount_unit" = 
		(SELECT CASE WHEN "foods"."type" = 'wet'  THEN (SELECT "cats"."food_cal"*"cats"."wet_percentage"*0.01/"foods"."cal_per_unit" FROM "cats" JOIN "cats_foods" ON "cats"."id" = "cats_foods"."cat_id"  JOIN "foods" ON "foods"."id" = "cats_foods"."food_id" WHERE "foods"."id" =1) 
	 				 WHEN "foods"."type" = 'dry' THEN (SELECT "cats"."food_cal"*(100-"cats"."wet_percentage")*0.01/"foods"."cal_per_unit" FROM "cats" JOIN "cats_foods" ON "cats"."id" = "cats_foods"."cat_id"  JOIN "foods" ON "foods"."id" = "cats_foods"."food_id" WHERE "foods"."id" =1) 	
	    END) ,
	 
"daily_amount_oz" = 
		(SELECT CASE WHEN "foods"."type" = 'wet'  THEN (SELECT "cats"."food_cal"*"cats"."wet_percentage"*0.01/("foods"."cal_per_kg"/35.274) FROM "cats" JOIN "cats_foods" ON "cats"."id" = "cats_foods"."cat_id"  JOIN "foods" ON "foods"."id" = "cats_foods"."food_id" WHERE "foods"."id" =1) 
	     	         WHEN "foods"."type" = 'dry' THEN (SELECT "cats"."food_cal"*(100-"cats"."wet_percentage")*0.01/("foods"."cal_per_kg"/35.274) FROM "cats" JOIN "cats_foods" ON "cats"."id" = "cats_foods"."cat_id"  JOIN "foods" ON "foods"."id" = "cats_foods"."food_id" WHERE "foods"."id" =1) 	
	     END)
	  
WHERE "foods"."id" = 1;
		


UPDATE "foods"
SET "daily_amount_unit" = 
 (CASE WHEN "cal_per_unit" IS NOT NULL THEN 
	(
		(SELECT CASE WHEN "foods"."type" = 'wet'  THEN (SELECT "cats"."food_cal"*"cats"."wet_percentage"*0.01/"foods"."cal_per_unit" FROM "cats" JOIN "cats_foods" ON "cats"."id" = "cats_foods"."cat_id"  JOIN "foods" ON "foods"."id" = "cats_foods"."food_id" WHERE "foods"."id" =1) 
	 				 WHEN "foods"."type" = 'dry' THEN (SELECT "cats"."food_cal"*(100-"cats"."wet_percentage")*0.01/"foods"."cal_per_unit" FROM "cats" JOIN "cats_foods" ON "cats"."id" = "cats_foods"."cat_id"  JOIN "foods" ON "foods"."id" = "cats_foods"."food_id" WHERE "foods"."id" =1) 	
	    END) 
	 ) 
	 
	 WHEN "cal_per_unit" IS NULL THEN 0
	   
        END),
	 
"daily_amount_oz" = 
 (CASE WHEN "cal_per_kg" IS NOT NULL THEN 
	(
		(SELECT CASE WHEN "foods"."type" = 'wet'  THEN (SELECT "cats"."food_cal"*"cats"."wet_percentage"*0.01/("foods"."cal_per_kg"/35.274) FROM "cats" JOIN "cats_foods" ON "cats"."id" = "cats_foods"."cat_id"  JOIN "foods" ON "foods"."id" = "cats_foods"."food_id" WHERE "foods"."id" =1) 
	     	         WHEN "foods"."type" = 'dry' THEN (SELECT "cats"."food_cal"*(100-"cats"."wet_percentage")*0.01/("foods"."cal_per_kg"/35.274) FROM "cats" JOIN "cats_foods" ON "cats"."id" = "cats_foods"."cat_id"  JOIN "foods" ON "foods"."id" = "cats_foods"."food_id" WHERE "foods"."id" =1) 	
	     END)
	  ) 
	  
	  WHEN "cal_per_kg" IS NULL THEN 0
	    
	     END)
WHERE "foods"."id" = 1;

