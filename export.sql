--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 9.6.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: gender; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE gender AS ENUM (
    'male',
    'female'
);


ALTER TYPE gender OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE account (
    id_account integer NOT NULL,
    login character varying(100) NOT NULL,
    password character varying(255) NOT NULL
);


ALTER TABLE account OWNER TO postgres;

--
-- Name: account_id_account_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE account_id_account_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE account_id_account_seq OWNER TO postgres;

--
-- Name: account_id_account_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE account_id_account_seq OWNED BY account.id_account;


--
-- Name: contact; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE contact (
    id_contact integer NOT NULL,
    id_person integer NOT NULL,
    id_contact_type integer NOT NULL,
    contact character varying(200) NOT NULL
);


ALTER TABLE contact OWNER TO postgres;

--
-- Name: contact_id_contact_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE contact_id_contact_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE contact_id_contact_seq OWNER TO postgres;

--
-- Name: contact_id_contact_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE contact_id_contact_seq OWNED BY contact.id_contact;


--
-- Name: contact_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE contact_type (
    id_contact_type integer NOT NULL,
    name character varying(200) NOT NULL,
    validation_regexp character varying(200) NOT NULL
);


ALTER TABLE contact_type OWNER TO postgres;

--
-- Name: contact_type_id_contact_type_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE contact_type_id_contact_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE contact_type_id_contact_type_seq OWNER TO postgres;

--
-- Name: contact_type_id_contact_type_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE contact_type_id_contact_type_seq OWNED BY contact_type.id_contact_type;


--
-- Name: location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE location (
    id_location integer NOT NULL,
    city character varying(200),
    street_name character varying(200),
    street_number integer,
    zip character varying(50),
    country character varying(200),
    name character varying(200),
    latitude numeric,
    longitude numeric
);


ALTER TABLE location OWNER TO postgres;

--
-- Name: location_id_location_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE location_id_location_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE location_id_location_seq OWNER TO postgres;

--
-- Name: location_id_location_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE location_id_location_seq OWNED BY location.id_location;


--
-- Name: meeting; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE meeting (
    id_meeting integer NOT NULL,
    start timestamp with time zone NOT NULL,
    description character varying(200) NOT NULL,
    duration time without time zone,
    id_location integer NOT NULL
);


ALTER TABLE meeting OWNER TO postgres;

--
-- Name: meeting_id_meeting_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE meeting_id_meeting_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE meeting_id_meeting_seq OWNER TO postgres;

--
-- Name: meeting_id_meeting_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE meeting_id_meeting_seq OWNED BY meeting.id_meeting;


--
-- Name: person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE person (
    id_person integer NOT NULL,
    nickname character varying(200) NOT NULL,
    first_name character varying(200) NOT NULL,
    last_name character varying(200) NOT NULL,
    id_location integer,
    birth_day date,
    height integer,
    gender gender,
    CONSTRAINT height_check CHECK ((height > 0))
);


ALTER TABLE person OWNER TO postgres;

--
-- Name: person_id_person_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE person_id_person_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE person_id_person_seq OWNER TO postgres;

--
-- Name: person_id_person_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE person_id_person_seq OWNED BY person.id_person;


--
-- Name: person_meeting; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE person_meeting (
    id_person integer NOT NULL,
    id_meeting integer NOT NULL
);


ALTER TABLE person_meeting OWNER TO postgres;

--
-- Name: relation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE relation (
    id_relation integer NOT NULL,
    id_person1 integer NOT NULL,
    id_person2 integer NOT NULL,
    description character varying(200) NOT NULL,
    id_relation_type integer NOT NULL
);


ALTER TABLE relation OWNER TO postgres;

--
-- Name: relation_id_relation_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE relation_id_relation_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE relation_id_relation_seq OWNER TO postgres;

--
-- Name: relation_id_relation_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE relation_id_relation_seq OWNED BY relation.id_relation;


--
-- Name: relation_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE relation_type (
    id_relation_type integer NOT NULL,
    name character varying(200) NOT NULL
);


ALTER TABLE relation_type OWNER TO postgres;

--
-- Name: relation_type_id_relation_type_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE relation_type_id_relation_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE relation_type_id_relation_type_seq OWNER TO postgres;

--
-- Name: relation_type_id_relation_type_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE relation_type_id_relation_type_seq OWNED BY relation_type.id_relation_type;


--
-- Name: account id_account; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY account ALTER COLUMN id_account SET DEFAULT nextval('account_id_account_seq'::regclass);


--
-- Name: contact id_contact; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY contact ALTER COLUMN id_contact SET DEFAULT nextval('contact_id_contact_seq'::regclass);


--
-- Name: contact_type id_contact_type; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY contact_type ALTER COLUMN id_contact_type SET DEFAULT nextval('contact_type_id_contact_type_seq'::regclass);


--
-- Name: location id_location; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY location ALTER COLUMN id_location SET DEFAULT nextval('location_id_location_seq'::regclass);


--
-- Name: meeting id_meeting; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY meeting ALTER COLUMN id_meeting SET DEFAULT nextval('meeting_id_meeting_seq'::regclass);


--
-- Name: person id_person; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY person ALTER COLUMN id_person SET DEFAULT nextval('person_id_person_seq'::regclass);


--
-- Name: relation id_relation; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY relation ALTER COLUMN id_relation SET DEFAULT nextval('relation_id_relation_seq'::regclass);


--
-- Name: relation_type id_relation_type; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY relation_type ALTER COLUMN id_relation_type SET DEFAULT nextval('relation_type_id_relation_type_seq'::regclass);


--
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY account (id_account, login, password) FROM stdin;
\.


--
-- Name: account_id_account_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('account_id_account_seq', 1, false);


--
-- Data for Name: contact; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY contact (id_contact, id_person, id_contact_type, contact) FROM stdin;
100	24	1	petal.leonora
101	28	1	summers.gilda
102	29	1	remona.deen.3
103	30	1	lisette.igneess
104	32	1	marcel.miranda.5
105	33	1	dion.leclaire.4
106	34	1	ericka.kreiner.1
35	8	3	724548217
36	9	3	725852711
37	10	3	773525542
39	12	3	723258369
40	13	3	774123475
41	14	3	735252756
42	15	3	728424666
43	16	3	726587663
44	17	3	726548723
45	18	3	724963797
47	20	3	775545965
48	21	3	772264852
49	22	3	721253542
50	23	3	722654752
51	24	3	731765214
52	25	3	774251714
53	26	3	774954246
54	27	3	732725825
55	28	3	734821462
56	29	3	732654654
57	30	3	775828254
59	32	3	775595419
60	33	3	723654179
61	34	3	776853578
1	1	4	ethyl.herren@gmail.com
2	2	4	temple.gumbs@outlook.com
3	3	4	tuan.brauer@gmail.com
4	4	4	everett.hilbert@live.com
5	5	4	karl.oshiro@gmail.com
6	6	4	glennie.hottinger@gmail.com
7	7	4	maddierankins@gmail.com
8	8	4	toledo.earlie@gmail.com
9	9	4	crandall@outlook.com
10	10	4	colangelo@live.com
12	12	4	edmann@hotmail.com
13	13	4	callender.jessica@gmail.com
14	14	4	rolando.lung@gmail.com
15	15	4	tommygun@yahoo.com
16	16	4	fucha@gmail.com
17	17	4	oshiro.karl@outlook.com
18	18	4	maglione.twyla@live.com
20	20	4	mckay.bess@gmail.com
21	21	4	lona@gmail.com
22	22	4	axeman5@gmail.com
23	23	4	clockMaster1@gmail.com
24	24	4	petal.nisbet@yahoo.com
25	25	4	knowsy@gmail.com
26	26	4	spacey.nisbet@outlook.com
27	27	4	slonaker@yahoo.com
28	28	4	summers54@gmail.com
29	29	4	hilary.deen@gmail.com
30	30	4	siqueiros@hotmail.com
32	32	4	leclaire@outlook.com
33	33	4	gene.dion@gmail.com
34	34	4	kiiny.ericka.kreiner@gmail.com
62	1	2	ethy12
63	2	2	temple.gumbs
64	3	2	hilbert3
65	4	2	everett
66	5	2	teague
67	6	2	kaneshiro
68	7	2	maddie.rankins
69	8	2	toledo3
70	9	2	bigbill
71	10	2	roderick
72	21	2	lona.sonny
73	22	2	tristan.axeman
74	23	2	clock-master
75	24	2	nisbet.petal
76	25	2	knowsy
77	26	2	spacey52
78	27	2	emiii4x4
79	28	2	gilda.summer
80	29	2	hilary.4
81	30	2	igneess
83	32	2	marcel.miranda
84	33	2	gene.dion
85	34	2	kreiner
108	47	4	frfr@gmail.com
109	47	4	francis.francoise@gmail.com
110	47	4	francoise.wood@gmail.com
86	8	1	earlie.toledo.1
87	9	1	bill.crandall.3
88	10	1	roderick.colangelo.1
90	12	1	julissa.erdmann
91	13	1	jesica.callender.3
92	14	1	rolando.lung.4
93	15	1	thomas.dowdle.1
94	16	1	fuchs.tuan
95	17	1	karl.oshi.1
96	20	1	bess.mckay
97	21	1	sonny.sonny
98	22	1	tristan.axeman
99	23	1	clockmaster.wingert
117	19	4	Arlette@email.com
\.


--
-- Name: contact_id_contact_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('contact_id_contact_seq', 117, true);


--
-- Data for Name: contact_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY contact_type (id_contact_type, name, validation_regexp) FROM stdin;
2	skype	
5	jabber	
6	web	
1	facebook	
4	email	
3	tel	\\+?([0-9]{3})?\\s*[0-9]{3}\\s*[0-9]{3}\\s*[0-9]{3}
\.


--
-- Name: contact_type_id_contact_type_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('contact_type_id_contact_type_seq', 7, true);


--
-- Data for Name: location; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY location (id_location, city, street_name, street_number, zip, country, name, latitude, longitude) FROM stdin;
49	Hradec Králové	Velké náměstí	26	500 03	\N	Kavárna U Knihomola	50.2096232	15.836109
37	Llanbedr Dyffryn Clwyd	Troed Y Fenlli	3	LL15 1BQ	United Kingdom	\N	53.1258941	-3.2826918
25	Hradec Králové	Govorova	628	500 06	\N	\N	\N	\N
23	Hradec Králové	Nový Hradec	754	500 06	\N	\N	\N	\N
12	Budišov nad Budišovkou	Halaškovo náměstí	178	747 87	\N	\N	49.7943254	17.6264516
26	Hradec Králové	Rokycanova	159	500 06	\N	\N	\N	\N
21	Portishead	Rodmoor Rd	\N	BS20 7HZ	United Kingdom	Portishead Bowling Club	51.4850746	-2.7710376
42	Brno	Kotlářská	10	602 00	\N	Rybářské potřeby U Sumce	49.2060867	16.599632
38	Düsseldorf	Elisabethstraße	40	40 217	Germany	\N	51.2148005	6.7745159
14	Samopše - Mrchojedy	\N	4	285 06	\N	Auto Body Shop	49.8630894	14.9288152
28	Lanškroun	Pražské předměstí	154	563 01	\N	\N	\N	\N
30	Luton	University Square	\N	LU1 3JU	United Kingdom	University of Bedfordshire, Luton Campus	51.9222583	-0.5311648
41	Brno	Zemědělská	1	613 00	\N	school	49.2100627	16.6168339
43	\N	\N	\N	\N	\N	Home	\N	\N
4	Bridge of Allan	Henderson St	15	FK9 4HN	United Kingdom	The Allanwater Cafe	56.1527769	-3.9491236
31	Pardubice	Mahonova	1530	532 01	\N	\N	\N	\N
22	Sharpness	The Docks	\N	GL13 9UN	United Kingdom	Sharpness Dockers Club	\N	\N
32	Pardubice	Přemyslova	1284	532 01	\N	\N	\N	\N
44	Brno	Vodova	336	612 00	\N	Hala Vodova	49.2273177	16.5827707
2	Castletown-Bearhaven	The Square	\N	\N	Ireland	Ring of Beara	51.6507621	-9.9103394
13	Nowa Wieś Wrocławska	Ulica Nowa	9	55-080	Poland	\N	51.0440184	16.9163198
33	Pardubice	Albertova	485	 	\N	\N	\N	\N
45	Brno	Gorkého	96	602 00	\N	U Bláhovky	49.1991243	16.5913443
46	Brno	\N	\N	\N	\N	under the clock	\N	\N
47	Brno	\N	\N	\N	\N	in the park	\N	\N
36	Prachatice	Pražská	103	383 01	\N	\N	\N	\N
48	Praha	Aviatická	2	161 00	\N	Terminal 1	50.1068145	14.2680641
6	Muir of Ord	Old Rd	182	IV6 7UJ	United Kingdom	Glen Ord Distillery	57.457622	-4.3236818
40	Albrechtice nad Orlicí	T. G. Masaryka	128	517 22	\N	\N	\N	\N
3	Stirling	Fountain Rd	27	FK9 4AT	United Kingdom	\N	56.1527769	-3.9491343
5	Vsetín	Sedličky	6	755 01	\N	\N	\N	\N
1	Holice	Nad Splavem	315	534 01	\N	\N	\N	\N
15	Přišimasy	\N	119	282 01	\N	\N	50.0523956	14.7588785
11	Inverness	Dochfour Drive	4	IV3 5EF	United Kingdom	\N	57.4770758	-4.2416873
9	Linz	Mozartstraße	33	4020	Austria	\N	48.3021472	14.2928913
8	Bremen	Doventorsteinweg	48	281 95	Germany	Agentur Für Arbeit	53.0855307	8.8007405
19	Hradec Králové	Rokitanského	62	500 03	\N	Univerzita Hradec Králové	50.2098593	15.8267625
20	Plzeň	Kollárova 	6	301 00 	\N	\N	49.7478082	13.3685989
39	Antwerpen	Jan van Rijswijcklaan	191	2020	Belgium	Antwerp Expo	51.1891488	4.397781
7	Linz	Promenade	39	4010	Austria	Landestheater Linz	48.2992233	14.2838151
35	Maastricht	Fort Willemweg	47	6219 PA	Netherlands	\N	50.8587113	5.6791561
17	Bad Zell	Linzer Straße	19	4283	Austria	\N	48.3464326	14.6626733
10	Holice	Husova	\N	534 01	\N	\N	\N	\N
16	Znojmo	Kuchařovická	1	669 02	\N	\N	48.8599039	16.0549261
51	Paris	Avenue Gustave Eiffel	\N	\N	\N	La Tour Eiffel	\N	\N
52	Brno	Žebětínek 7a	\N	62100	\N	\N	\N	\N
27	Llanfairpwllgwyngyll	Ffordd Penmynydd	5	LL61 6UX	United Kingdom	\N	53.2236409	-4.2026051
55	Brno	Žebětínek 7a	-1	62100	\N	\N	\N	\N
56	Brno	Žebětínek 7a	1	62100	\N	\N	\N	\N
57	Brno	Žebětínek 7a	\N	62100	\N	\N	\N	\N
24	Bolton	Davenport	12	BL1 2LT	United Kingdom	\N	53.5834001	-2.4346145
29	Lanškroun	Zámecká	419	563 01	\N	\N	\N	\N
58	\N	dfg	\N	\N	\N	\N	\N	\N
59	Nitra	asdda	-1	940	\N	\N	\N	\N
60	Brno	Žebětínek 7a	\N	62100	\N	\N	\N	\N
61	Nitra	dfgdgf	45	940	\N	\N	\N	\N
62	\N	\N	\N	\N	\N	\N	\N	\N
63	\N	\N	\N	\N	\N	\N	\N	\N
64	\N	\N	\N	\N	\N	\N	\N	\N
34	Bremen	Katrepeler Straße	45	282 15	Germany	\N	53.0927528	8.8061181
65	Nitra	asdda	5	940	\N	\N	\N	\N
66	Nitra	asdda	5	940	\N	\N	\N	\N
67	Nitra	asdda	1	940	\N	\N	\N	\N
68	Nitra	asdda	1	940	\N	\N	\N	\N
69	Nitra	asdda	1	940	\N	\N	\N	\N
18	Meziměstí	Školn	85	549 81	\N	\N	50.6257013	16.2414235
\.


--
-- Name: location_id_location_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('location_id_location_seq', 69, true);


--
-- Data for Name: meeting; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY meeting (id_meeting, start, description, duration, id_location) FROM stdin;
2	2016-09-17 09:30:00+00		\N	42
3	2016-09-06 07:30:00+00	electrician	01:30:00	43
11	2016-10-26 16:00:00+00	window cleaners	\N	43
15	2016-09-24 10:30:00+00	lunch	\N	43
4	2016-08-31 10:00:00+00		\N	45
14	2016-12-07 16:00:00+00		\N	45
7	2016-10-18 07:30:00+00	fishing eqp	\N	31
13	2016-12-05 08:30:00+00	fishing eqp	\N	12
5	2016-09-15 17:30:00+00	flowers!	\N	46
10	2016-09-24 14:30:00+00		\N	47
12	2016-08-18 11:30:00+00		00:30:00	47
16	2016-12-05 19:30:00+00		\N	47
17	2016-09-06 13:00:00+00	pickup	\N	48
8	2016-09-21 11:30:00+00	lunch	02:00:00	49
6	2016-09-17 09:30:00+00		\N	28
9	2016-12-05 13:00:00+00		\N	41
1	2016-12-25 14:00:00+00	books	\N	41
18	2021-01-13 12:32:00+00	vylet do Brna	05:30:00	14
\.


--
-- Name: meeting_id_meeting_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('meeting_id_meeting_seq', 65, true);


--
-- Data for Name: person; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY person (id_person, nickname, first_name, last_name, id_location, birth_day, height, gender) FROM stdin;
22	axeMan	Tristan	Gory	20	1968-08-21	194	male
21	Sony	Sonny	Lona	19	1982-06-19	160	male
23	Clock-Master	Lincoln	Wingert	21	1975-11-18	185	male
32	Leclaire	Marcel	Miranda	28	1976-11-28	\N	male
41	zachy	Zachery	Figueiredo	37	1982-07-07	175	male
40	LouReed	Reed	Judah	36	1986-05-11	190	male
16	Fucha	Tuan	Fuchs	20	1952-11-02	168	male
39	Swordy	Justin	Wess	35	1967-09-08	178	male
17	Oshi	Karl	Oshiro	16	1980-12-20	177	male
38	8al	Florentino	Balfour	34	1966-03-16	173	male
5	Teague	Karl	Oshiro	5	1980-03-09	\N	male
4	Bertie	Everett	Hilbert	4	1983-05-25	172	male
3	Tungsten	Tuan	Brauer	3	1982-01-20	180	male
9	BigBill	Bill	Crandall	9	1982-02-24	175	male
10	Usher	Roderick	Colangelo	10	1981-05-13	\N	male
15	TommyGun	Thomas	Dowdle	14	1989-12-01	162	male
14	Lungs	Rolando	Lung	13	1974-11-29	178	male
24	Petal	Leonora	Nisbet	21	1978-05-26	172	female
46	Agan	Opal	Bagg	\N	\N	183	female
26	Spacey	Leonora	Nisbet	\N	1971-01-12	185	female
47	Francis	Francoise	Wood	\N	1980-03-12	\N	female
25	Know$y	Janey	Knowlton	22	1985-11-09	165	female
29	hilary	Remona	Deen	25	\N	170	female
30	Igneess	Lisette	Siqueiros	26	\N	170	female
28	Summers	Gilda	Summer	24	1973-03-18	168	female
34	Kiiny	Ericka	Kreiner	30	1978-06-30	182	female
2	Gumby	Temple 	Gumbs	2	\N	184	female
37	cutty	Nelia	Cutter	33	1965-02-12	169	female
36	pPhil	Phyliss	Metheny	32	1980-05-16	166	female
35	fox	Meagan	Holst	31	1979-12-31	176	female
7	mara	Maddie	Rankins	7	1979-10-11	185	female
6	Kaneshiro	Glennie	Hottinger	6	1982-10-20	161	female
8	Toledo	Earlie	Toledo	8	1986-04-29	194	female
13	january	Jesica	Callender	12	1964-10-09	174	female
12	Julerd	Julissa	Erdmann	10	1985-07-27	173	female
42	Tanaka	Goldie	Steen	39	1985-01-13	181	female
20	Bessie	Bess	Mckay	19	1979-09-30	159	female
18	Magnolia	Twyla	Maglione	17	1942-07-16	180	female
43	homa	Hong	Maday	40	1980-05-16	164	male
27	Emiii4x4	Barton	Slonaker	24	1972-02-15	177	male
33	Gene	Dio	Leclaire	29	1977-12-21	163	male
49	hiromi	Carl	Oshiro	61	2021-01-21	10	male
45	Kami	Dexter	Pagano	64	2021-01-13	\N	male
1	Ethy	Ethyl	Herren	34	1968-09-06	164	female
19	Arlene	Arlette	Woodfords	18	1946-01-15	45	male
\.


--
-- Name: person_id_person_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('person_id_person_seq', 68, true);


--
-- Data for Name: person_meeting; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY person_meeting (id_person, id_meeting) FROM stdin;
1	1
2	1
3	1
4	1
5	1
2	2
3	2
4	3
32	3
5	4
29	4
6	5
7	5
8	6
10	6
12	6
14	6
24	6
25	6
29	6
34	6
35	6
36	6
38	6
13	7
17	7
20	7
22	7
26	7
28	7
32	7
33	7
3	8
4	8
5	8
6	8
7	8
8	8
10	8
15	9
16	10
34	10
1	11
15	11
39	11
40	11
41	11
13	12
17	12
22	12
34	12
35	12
36	12
4	13
33	13
15	14
16	14
21	14
24	14
32	14
33	14
34	14
35	14
36	14
41	14
3	15
37	15
5	16
30	16
5	17
6	17
14	17
15	17
30	17
32	17
39	17
18	18
19	18
23	18
27	18
33	18
\.


--
-- Data for Name: relation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY relation (id_relation, id_person1, id_person2, description, id_relation_type) FROM stdin;
1	20	21		8
2	23	24		8
5	5	36		8
7	20	12		7
8	18	16		7
9	10	29		7
12	14	24		7
13	3	25		7
14	1	24		4
15	1	25		4
16	2	26		4
17	2	30		4
18	2	35		4
21	3	16		4
22	3	24		4
23	3	32		4
24	3	36		4
25	4	15		4
26	4	21		4
27	4	23		4
28	4	12		4
29	5	17		4
32	5	29		4
33	5	32		4
34	5	34		4
35	6	17		4
37	8	22		4
41	6	36		6
42	1	30		6
43	15	29		6
44	2	32		1
45	9	21		1
46	10	21		1
47	15	21		1
48	2	25		1
49	2	27		1
50	10	27		1
52	12	25		1
53	12	27		1
54	12	28		1
56	14	33		1
57	16	22		1
59	17	34		1
60	18	37		1
61	18	22		1
62	18	29		1
65	20	27		1
68	35	36		1
70	21	34		1
71	21	35		1
72	22	23		1
73	17	34		5
74	18	37		5
76	18	29		5
79	20	27		5
80	21	27		5
82	1	21		2
83	3	23		2
84	5	24		2
86	7	32		2
87	7	34		2
89	5	34		2
90	1	24		2
4	3	37	12.3.2015	8
6	6	3	4.9.2014	8
3	1	39	23.5.2016	8
19	2	6	school	4
20	2	8	school	4
31	5	22	school	4
40	5	34	not sure	6
66	21	27	hiking	1
75	18	22	hiking	5
85	6	28	owes 15k	2
88	6	34	owes 54k	2
123	19	49	father	7
\.


--
-- Name: relation_id_relation_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('relation_id_relation_seq', 123, true);


--
-- Data for Name: relation_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY relation_type (id_relation_type, name) FROM stdin;
1	friend
2	enemy
3	partner
4	colleague
5	acquaintance
6	lover
7	family
8	spouse
\.


--
-- Name: relation_type_id_relation_type_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('relation_type_id_relation_type_seq', 9, true);


--
-- Name: account account_login_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY account
    ADD CONSTRAINT account_login_key UNIQUE (login);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id_account);


--
-- Name: contact contact_id_person_id_contact_type_contact_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY contact
    ADD CONSTRAINT contact_id_person_id_contact_type_contact_key UNIQUE (id_person, id_contact_type, contact);


--
-- Name: contact contact_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY contact
    ADD CONSTRAINT contact_pkey PRIMARY KEY (id_contact);


--
-- Name: contact_type contact_type_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY contact_type
    ADD CONSTRAINT contact_type_name_key UNIQUE (name);


--
-- Name: contact_type contact_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY contact_type
    ADD CONSTRAINT contact_type_pkey PRIMARY KEY (id_contact_type);


--
-- Name: location location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY location
    ADD CONSTRAINT location_pkey PRIMARY KEY (id_location);


--
-- Name: meeting meeting_start_id_location_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY meeting
    ADD CONSTRAINT meeting_start_id_location_key UNIQUE (start, id_location);


--
-- Name: person person_first_name_last_name_nickname_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY person
    ADD CONSTRAINT person_first_name_last_name_nickname_key UNIQUE (first_name, last_name, nickname);


--
-- Name: person_meeting person_meeting_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY person_meeting
    ADD CONSTRAINT person_meeting_pkey PRIMARY KEY (id_person, id_meeting);


--
-- Name: person person_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY person
    ADD CONSTRAINT person_pkey PRIMARY KEY (id_person);


--
-- Name: relation relation_id_person1_id_person2_id_relation_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY relation
    ADD CONSTRAINT relation_id_person1_id_person2_id_relation_type_key UNIQUE (id_person1, id_person2, id_relation_type);


--
-- Name: relation relation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY relation
    ADD CONSTRAINT relation_pkey PRIMARY KEY (id_relation);


--
-- Name: relation_type relation_type_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY relation_type
    ADD CONSTRAINT relation_type_name_key UNIQUE (name);


--
-- Name: relation_type relation_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY relation_type
    ADD CONSTRAINT relation_type_pkey PRIMARY KEY (id_relation_type);


--
-- Name: meeting schuzky_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY meeting
    ADD CONSTRAINT schuzky_pkey PRIMARY KEY (id_meeting);


--
-- Name: fki_meeting; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_meeting ON meeting USING btree (id_location);


--
-- Name: contact contact_id_contact_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY contact
    ADD CONSTRAINT contact_id_contact_type_fkey FOREIGN KEY (id_contact_type) REFERENCES contact_type(id_contact_type) ON DELETE CASCADE;


--
-- Name: contact contact_id_person_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY contact
    ADD CONSTRAINT contact_id_person_fkey FOREIGN KEY (id_person) REFERENCES person(id_person) ON DELETE CASCADE;


--
-- Name: meeting meeting_id_location_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY meeting
    ADD CONSTRAINT meeting_id_location_fkey FOREIGN KEY (id_location) REFERENCES location(id_location) ON DELETE CASCADE;


--
-- Name: person person_id_location_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY person
    ADD CONSTRAINT person_id_location_fkey FOREIGN KEY (id_location) REFERENCES location(id_location) ON DELETE CASCADE;


--
-- Name: person_meeting person_meeting_id_meeting_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY person_meeting
    ADD CONSTRAINT person_meeting_id_meeting_fkey FOREIGN KEY (id_meeting) REFERENCES meeting(id_meeting) ON DELETE CASCADE;


--
-- Name: person_meeting person_meeting_id_person_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY person_meeting
    ADD CONSTRAINT person_meeting_id_person_fkey FOREIGN KEY (id_person) REFERENCES person(id_person) ON DELETE CASCADE;


--
-- Name: relation relation_id_person1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY relation
    ADD CONSTRAINT relation_id_person1_fkey FOREIGN KEY (id_person1) REFERENCES person(id_person) ON DELETE CASCADE;


--
-- Name: relation relation_id_person2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY relation
    ADD CONSTRAINT relation_id_person2_fkey FOREIGN KEY (id_person2) REFERENCES person(id_person) ON DELETE CASCADE;


--
-- Name: relation relation_id_relation_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY relation
    ADD CONSTRAINT relation_id_relation_type_fkey FOREIGN KEY (id_relation_type) REFERENCES relation_type(id_relation_type) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

