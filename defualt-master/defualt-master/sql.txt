select * from take2;		 			//take2라는 테이블을 나열
select steamid from take2; 			// take2라는 테이블에서 모든 고유번호를 찾는다.
select distinct level from take2;	//take2라는 테이블에 레벨중에서 중복된건 제외하고 나열
select * from take2 where steamid = '%s' // take2라는 테이블에 steamid에서 %s에 맞는 고유번호를 찾는다
select * from take2 where level = 3 or level = 4; //take2라는 테이블에 레벨 3과 레벨 4를 찾는다.
select * from take2 where steamid = '%s' or steamid = '%s';
select * from take2 order by level; //take2라는 테이블에 level을 오름차순으로 나열 오름차순은 1부터 커짐
select * from take2 order by level desc; //내림차순

insert into take2 (steamid, level) values ('%s', '%d'); //take2라는 테이블에 steamid와 레벨을 집어넣는다

update take2 set level = '%d' where steamid = '%s'; // take2라는 테이블에 고유번호에 맞는 곳에 레벨을 업데이트 한다

delete from take2 where steamid = '%s' and level = '%d'; //take2라는 테이블에서 고유번호와 레벨을 삭제한다

select level,aa from take2 order by level desc limit 10

select * from take2 order by level desc limit 10

select * from take2 where level like '21'; //take2라는 테이블에서 레벨 21이 들어가는 레벨 나열 (214 1213 9992199)

select * from take2 where level in (1, 3); //웨얼인경우 1개만 나오지만 in이 있을땐 여러개가 나옴 1레벨과 3레벨인 모든 걸 나열!

select * from where level between 1 and 5; //레벨 1과 5 사이 나열 (1.2 3.4 4.5)

not을 붙이면 1과 5 사이가 아닌 다른 숫자를 나열

select * from take2 where (level between 1 and 5) and not exp in(75, 85, 90); //레벨은 1과 5사이 경험치는 75 85 90아닌 것

select * from take2 where name between 'a' and 'c'; //이름이 a부터 c까지

create table if not exists take2(steamid varchar(64) not null primary key, name varchar(64) not null, ENGINE=MyISAM DEFAULT CHARSET=utf8;);
if not exists // 존재하지 않은 경우
//insert나 update에 낫널 구문이 없다면 업데이트가 안됨 고로 고유번호나 닉네임을 적지 않는다면 아예 에러가 남 무조건 적어야댐
