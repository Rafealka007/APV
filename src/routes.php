<?php

use \Psr\Http\Message\ServerRequestInterface as Request;
use \Psr\Http\Message\ResponseInterface as Response;

include 'location.php';

$app->get('/', function (Request $request, Response $response, $args) {
    // Render index view
    return $this->view->render($response, 'index.latte');
})->setName('index');


/* SEZNAM vsech */
$app->get('/persons', function (Request $request, Response $response, $args) {
    $stmt = $this->db->query('SELECT * FROM person ORDER BY first_name');
    $tplVars['persons_list'] = $stmt->fetchall();
    return $this->view->render($response, 'persons.latte', $tplVars);
});

/*VYHLEDAVANI*/
$app->get('/search', function (Request $request, Response $response, $args) {
    $queryParams = $request->getQueryParams();
    if(! empty($queryParams) ) {
        $stmt = $this->db->prepare("SELECT * FROM person WHERE lower(first_name) = lower(:fname) OR lower(last_name) = lower(:lname)");
        $stmt->bindParam(':fname', $queryParams['q']);
        $stmt->bindParam(':lname', $queryParams['q']);
        $stmt->execute();
        $tplVars['persons_list'] = $stmt->fetchall();
        return $this->view->render($response, 'persons.latte', $tplVars);
    }
})->setName('search');


/* PERSON nacteni nove person */
$app->get('/person', function (Request $request, Response $response, $args) {
    return $this->view->render($response, 'newPerson.latte');
})->setName('newPerson');

/* PERSON zpracovani new */
$app->post('/person', function (Request $request, Response $response, $args) {
    $formData = $request->getParsedBody();
    $tplVars = [];
    if ( empty($formData['first_name']) || empty($formData['last_name']) || empty($formData['nickname']) ) {
        $tplVars['message'] = 'Please fill required fields';
    } else {
        try {
            $this->db->beginTransaction();
            if( !empty($formData["street_name"]) || !empty($formData["street_number"])
                || !empty($formData["city"]) || !empty($formData["zip"])){
                $id_location = newLocation($this, $formData);
            }
            $stmt = $this->db->prepare("INSERT INTO person (nickname, first_name, last_name, id_location, birth_day, height, gender) VALUES (:nickname, :first_name, :last_name, :id_location, :birth_day, :height, :gender)");
            $stmt->bindValue(':nickname', $formData['nickname']);
            $stmt->bindValue(':first_name', $formData['first_name']);
            $stmt->bindValue(':last_name', $formData['last_name']);
            $stmt->bindValue(':id_location', $id_location ? $id_location : null);
            $stmt->bindValue(':gender', empty($formData['gender']) ? null : $formData['gender'] ) ;
            $stmt->bindValue(':birth_day', empty($formData['birth_day']) ? null : $formData['birth_day']);
            $stmt->bindValue(':height', empty($formData['height']) ? null : $formData['height']);
            $stmt->execute();
            $this->db->commit();
        } catch (PDOexception $e) {
            $tplVars['message'] = 'Error occured, sorry jako';
            $this->logger->error($e->getMessage());
            $this->db->rollback();
        }
    }

    $this->view->render($response, 'newPerson.latte', $tplVars);
    $basePath = $request->getUri()->getBasePath();
    return $response->withRedirect($basePath."/persons");
});

/* person update nacteni formulare */
$app->get('/person/update', function (Request $request, Response $response, $args) {
    $params = $request->getQueryParams();
    $id_person = $request->getQueryParam('id_person');
    if (! empty($params["id_person"])){
        print_r($params["id_person"]);
        print_r($id_person);
        $stmt = $this->db->prepare("SELECT * FROM person
									LEFT JOIN location USING (id_location)
									WHERE id_person = :id_person");
        $stmt->bindValue(":id_person", $id_person);
        $stmt->execute();
        $tplVars["formData"] = $stmt->fetch();
        if (empty($tplVars["formData"])){
            exit("person not found");
        } else {
            return $this->view->render($response, 'updatePerson.latte', $tplVars);
        }
    }
})->setName("updatePerson");

/*person update prace s formularem */
$app->post("/person/update", function (Request $request, Response $response, $args){
    $id_person = $request->getQueryParam('id_person');
    $formData = $request->getParsedBody();
    if (empty($formData["first_name"]) || empty($formData["last_name"]) || empty($formData["nickname"])){
        $tplVars["message"] = "Please fill required fields";
    } else{
        try {
            if( !empty($formData["street_name"]) || !empty($formData["street_number"])
                || !empty($formData["city"]) || !empty($formData["zip"])){

                $stmt = $this->db->prepare("SELECT id_location FROM person WHERE id_person = :id_person");
                $stmt->bindValue(":id_person", $id_person);
                $stmt->execute();
                $id_location = $stmt->fetch()["id_location"];

                if($id_location){
                    editLocation($this, $id_location, $formData);
                } else{
                    $id_location = newLocation($this, $formData);
                }
            }else{
                $id_location = newLocation($this, $formData);
            }

            $stmt = $this->db->prepare("UPDATE person SET first_name = :first_name, 
														  last_name = :last_name,
														  nickname = :nickname, 
														  birth_day = :birth_day, 
														  gender = :gender, 
														  height = :height, 
														  id_location = :id_location
													  WHERE id_person = :id_person");
            $stmt->bindValue(":nickname", $formData["nickname"]);
            $stmt->bindValue(":first_name", $formData["first_name"]);
            $stmt->bindValue(":last_name", $formData["last_name"]);
            $stmt->bindValue(":id_location", $id_location ? $id_location : null);
            $stmt->bindValue(":gender", empty($formData["gender"]) ? null : $formData["gender"]);
            $stmt->bindValue(":height", empty($formData["height"]) ? null : $formData["height"]);
            $stmt->bindValue(":birth_day", $formData["birth_day"]);
            $stmt->bindValue(':id_person', $id_person);
            $stmt->execute();
        } catch (PDOexception $e) {

        }
    }
    $tplVars["formData"] = $formData;
    $this->view->render($response, 'updatePerson.latte', $tplVars);
    $basePath = $request->getUri()->getBasePath();
    return $response->withRedirect($basePath."/persons");
});


/* delete osob */
$app->post('/person/delete', function (Request $request, Response $response, $args) {
    $id_person = $request->getQueryParam('id_person');
    if (!empty($id_person)) {
        try {
            $stmt = $this->db->prepare('DELETE FROM person WHERE id_person = :id_person');
            $stmt->bindValue(':id_person', $id_person);
            $stmt->execute();
        } catch (PDOexception $e) {
            $this->logger->error($e->getMessage());
            exit('error occured');
        }
    } else {
        exit('person is missing');
    }
    $basePath = $request->getUri()->getBasePath();
    return $response->withRedirect($basePath."/persons");
})->setName('person_delete');

/*PERSON INFO*/
$app->get('/person/info', function (Request $request, Response $response, $args) {
    $id_person = $request->getQueryParam('id_person');
    if (!empty($id_person)) {
        try {
            $stmt = $this->db->prepare('SELECT DISTINCT * FROM person INNER JOIN location USING (id_location)
                                        WHERE id_person = :id_person');
            $stmt->bindValue(':id_person', $id_person);
            $stmt->execute();
            $tplVars['person'] = $stmt->fetchall();
            $stmt = $this->db->prepare('SELECT DISTINCT * FROM person INNER JOIN contact USING (id_person)
                                        INNER JOIN contact_type USING (id_contact_type) WHERE id_person = :id_person');
            $stmt->bindValue(':id_person', $id_person);
            $stmt->execute();
            $tplVars['contact'] = $stmt->fetchall();

            $stmt = $this->db->prepare('SELECT DISTINCT id_person as my_id,person.first_name as my_name, person.last_name as my_name_2,name, id_relation, friend_first_name, friend_last_name,description FROM person 
                                        INNER JOIN relation ON (person.id_person = relation.id_person1)
                                        INNER JOIN relation_type USING (id_relation_type)
                                        INNER JOIN (SELECT DISTINCT id_person AS friend_id, first_name AS friend_first_name, last_name AS friend_last_name FROM person) AS friend ON (id_person2 = friend.friend_id)
                                        WHERE id_person = :id_person');
            $stmt->bindValue(':id_person', $id_person);
            $stmt->execute();
            $tplVars['relation'] = $stmt->fetchall();

            $stmt = $this->db->prepare('SELECT DISTINCT id_person as my_id,person.first_name as my_name, person.last_name as my_name_2, name, id_relation, friend_first_name, friend_last_name,description FROM person 
                                        INNER JOIN relation ON (person.id_person = relation.id_person2)
                                        INNER JOIN relation_type USING (id_relation_type)
                                        INNER JOIN (SELECT DISTINCT id_person AS friend_id, first_name AS friend_first_name, last_name AS friend_last_name FROM person) AS friend ON (id_person1 = friend.friend_id)
                                        WHERE id_person = :id_person');
            $stmt->bindValue(':id_person', $id_person);
            $stmt->execute();
            $tplVars['relation2'] = $stmt->fetchall();


        } catch (PDOexception $e) {
            $this->logger->error($e->getMessage());
            exit('error occured');
        }
    } else {
        exit('is person is missing');
    }

    return $this->view->render($response, 'infoPerson.latte', $tplVars);

})->setName("infoPerson");



/*RELATIONS ADD Nacteni formulare*/
$app->get('/person/addRelation', function (Request $request, Response $response, $args) {
    $stmt = $this->db->prepare("SELECT * FROM person ORDER BY first_name");
    $stmt->execute();
    $tplVars["person"] = $stmt->fetchall();
    $stmt = $this->db->prepare("SELECT * FROM relation_type");
    $stmt->execute();
    $tplVars["relation"] = $stmt->fetchall();
    return $this->view->render($response, 'addRelation.latte', $tplVars);
})->setName("addRelation");

/*RELATIONS ADD Insert*/
$app->post('/person/addRelation', function (Request $request, Response $response, $args) {
    $formData = $request->getParsedBody();
    $id_person = $request->getQueryParam('id_person');
    if (!empty($id_person)) {
        try {
            $stmt = $this->db->prepare('INSERT INTO relation (id_person1, id_person2, description, id_relation_type) VALUES (:id_person1, :id_person2, :description, :id_relation_type)');
            $stmt->bindValue(':id_person1', $id_person);
            $stmt->bindValue(':id_person2', $formData['id_person2']);
            $stmt->bindValue(':description', $formData['description']);
            $stmt->bindValue(':id_relation_type', $formData['id_relation_type']);
            $stmt->execute();
        } catch (PDOexception $e) {
            $this->logger->error($e->getMessage());
            exit($id_person);
        }
    } else {
        exit('Error in id_person');
    }
    $basePath = $request->getUri()->getBasePath();
    return $response->withRedirect($basePath."/person/info?id_person=".$id_person);
})->setName('addRelations');

/*DELETE relations */
$app->post('/person/infoPerson/removeRelations', function (Request $request, Response $response, $args) {
    $id_relation = $request->getQueryParam('id_relation');
    try {
        $stmt = $this->db->prepare('DELETE FROM relation WHERE id_relation = :id_relation');
        $stmt->bindValue(':id_relation', $id_relation);
        $stmt->execute();
    } catch (PDOexception $e) {
        $this->logger->error($e->getMessage());
        exit('error occured');
    }
    $basePath = $request->getUri()->getBasePath();
    return $response->withRedirect($basePath."/person/info?id_person=".$_POST['id_person']);
})->setName("removeRelation");



/*CONTACT Nacteni formulare*/
$app->get('/person/addContact', function (Request $request, Response $response, $args) {
    $stmt = $this->db->prepare("SELECT * FROM contact_type ORDER BY name");
    $stmt->execute();
    $tplVars["contact"] = $stmt->fetchall();
    $stmt = $this->db->prepare("SELECT * FROM person ORDER BY first_name");
    $stmt->execute();
    $tplVars["person"] = $stmt->fetchall();
    return $this->view->render($response, 'addContact.latte', $tplVars);
})->setName("addContact");


/*ADD contact*/
$app->post('/person/addContact', function (Request $request, Response $response, $args) {
    $formData = $request->getParsedBody();
    $id_person = $request->getQueryParam('id_person');
    print_r($id_person);
    print_r($formData);
    if (!empty($id_person)) {
        try {
            $stmt = $this->db->prepare('INSERT INTO contact (id_person, id_contact_type, contact) VALUES (:id_person, :id_contact_type, :contact)');
            $stmt->bindValue(':id_person', $id_person);
            $stmt->bindValue(':id_contact_type', $formData['id_contact_type']);
            $stmt->bindValue(':contact', $formData['contact']);
            $stmt->execute();
            printf($id_person);
        } catch (PDOexception $e) {
            $this->logger->error($e->getMessage());
            exit();
        }
    } else {
        exit('Error in id_person');
    }
    $basePath = $request->getUri()->getBasePath();
    return $response->withRedirect($basePath."/person/info?id_person=".$id_person);
})->setName('addContact');

/* DELETE contact */
$app->post('/person/infoPerson/removeContact', function (Request $request, Response $response, $args) {
    $id_contact = $request->getQueryParam('id_contact');
    try {
        $stmt = $this->db->prepare('DELETE FROM contact WHERE id_contact = :id_contact');
        $stmt->bindValue(':id_contact', $id_contact);
        $stmt->execute();
    } catch (PDOexception $e) {
        $this->logger->error($e->getMessage());
        exit('error occured');
    }
    $basePath = $request->getUri()->getBasePath();
    return $response->withRedirect($basePath."/person/info?id_person=".$_POST['id_person']);
})->setName("removeContact");












/*MEETINGS vypis vsech*/
$app->get('/meetings', function (Request $request, Response $response, $args) {
    $stmt = $this->db->query('SELECT * FROM meeting ORDER BY id_meeting DESC');
    $tplVars['meeting_list'] = $stmt->fetchall();
    return $this->view->render($response, 'meetings.latte', $tplVars);
});

/* NEW MEETING nacteni formulare*/
$app->get('/meeting', function (Request $request, Response $response, $args) {
    $stmt = $this->db->query('SELECT * FROM location INNER JOIN person USING (id_location)');
    $tplVars['location_list'] = $stmt->fetchall();
    return $this->view->render($response, 'newMeeting.latte', $tplVars);
})->setName('newMeeting');

/* NEW MEETING zpracovani formulare po odeslani */
$app->post('/meeting', function (Request $request, Response $response, $args) {
    $formData = $request->getParsedBody();
    #print_r($formData);
    #print_r($_POST['people']);
    $temp = $_POST['people'];
    $dbDate = date('Y-m-d H:i:s', strtotime($_POST["start"]));
    try {
        $stmt = $this->db->prepare("INSERT INTO meeting (start, description, duration, id_location) VALUES (:start, :description, :duration, :id_location)");
        $stmt->bindValue(':start', $dbDate);
        $stmt->bindValue(':description', $formData['description']);
        $stmt->bindValue(':duration', $formData['duration']);
        $stmt->bindValue(':id_location', $formData['id_location']);
        $stmt->execute();
        $stmt = $this->db->prepare("SELECT id_meeting FROM meeting WHERE (id_location=:id_location AND start=:start AND duration=:duration AND description=:description)");
        $stmt->bindValue(':start', $dbDate);
        $stmt->bindValue(':description', $formData['description']);
        $stmt->bindValue(':duration', $formData['duration']);
        $stmt->bindValue(':id_location', $formData['id_location']);
        $stmt->execute();
        $tplVars["id_meeting"] = $stmt->fetch();
        foreach ($temp as $person) {
            $stmt = $this->db->prepare("INSERT INTO person_meeting (id_meeting, id_person) VALUES (:id_meeting, :id_person)");
            $stmt->bindValue(':id_meeting', $tplVars["id_meeting"]['id_meeting']);
            $stmt->bindValue(':id_person', $person);
            $stmt->execute();
        }
    } catch (PDOexception $e) {
        $tplVars['message'] = 'Error occured';
        $this->logger->error($e->getMessage());
    }
    $basePath = $request->getUri()->getBasePath();
    return $response->withRedirect($basePath."/meetings");
});

/*INFO Meeting vypis*/
$app->get('/meeting/info', function (Request $request, Response $response, $args) {
    $id_meeting = $request->getQueryParam('id_meeting');
    try {
        $stmt = $this->db->prepare('SELECT DISTINCT * FROM meeting INNER JOIN location USING (id_location)
                                    WHERE id_meeting = :id_meeting');
        $stmt->bindValue(':id_meeting', $id_meeting);
        $stmt->execute();
        $tplVars['meeting'] = $stmt->fetchall();

        $stmt = $this->db->prepare('SELECT DISTINCT * FROM meeting INNER JOIN person_meeting USING (id_meeting) 
                                    INNER JOIN person USING (id_person)
                                    WHERE id_meeting = :id_meeting');
        $stmt->bindValue(':id_meeting', $id_meeting);
        $stmt->execute();
        $tplVars['person'] = $stmt->fetchall();

    } catch (PDOexception $e) {
        $this->logger->error($e->getMessage());
        exit('error occured');
    }
    return $this->view->render($response, 'infoMeeting.latte', $tplVars);
})->setName("infoMeeting");



// UPDATE MEETING nacteni formulare
$app->get('/meeting/update', function (Request $request, Response $response, $args) {
    $params = $request->getQueryParams();
    if (!empty($params['id_meeting'])){
        $stmt = $this->db->prepare("SELECT * FROM meeting INNER JOIN location USING (id_location) WHERE id_meeting = :id_meeting");
        $stmt->bindValue(":id_meeting", $params['id_meeting']);
        $stmt->execute();
        $tplVars["formData"] = $stmt->fetch();

        $stmt = $this->db->query('SELECT * FROM location INNER JOIN person USING (id_location)');
        $stmt->execute();
        $tplVars['location_list'] = $stmt->fetchall();
        if (empty($tplVars["formData"])){
            exit("Meeting not found");
        } else {
            return $this->view->render($response, 'updateMeeting.latte', $tplVars);
        }
    }
})->setName("updateMeeting");

// UPDATE MEETING prace s formularem
$app->post("/meeting/update", function (Request $request, Response $response, $args){
    $formData = $request->getParsedBody();
    print_r($formData);
    $dbDate = date('Y-m-d H:i:s', strtotime($_POST["start"]));
    try {
        $stmt = $this->db->prepare("UPDATE meeting SET  start=:start,
														description = :description,
														duration = :duration, 
														id_location = :id_location 
                                    WHERE id_meeting = :id_meeting");
        $stmt->bindValue(":start", $dbDate);
        $stmt->bindValue(":id_meeting",$formData["id_meeting"]);
        $stmt->bindValue(":description", $formData["description"]);
        $stmt->bindValue(":duration", $formData["duration"]);
        $stmt->bindValue(":id_location", $formData["id_location"]);
        $stmt->execute();
    } catch (PDOexception $e) {
        $tplVars['message'] = 'Error occured in updatemeeting';
    }
    $basePath = $request->getUri()->getBasePath();
    return $response->withRedirect($basePath."/meetings");
});





/*DELETE Meeting*/
$app->post('/meeting/delete', function (Request $request, Response $response, $args) {
    $id_meeting = $request->getQueryParam('id_meeting');
    try {
        $stmt = $this->db->prepare('DELETE FROM meeting WHERE id_meeting = :id_meeting');
        $stmt->bindValue(':id_meeting', $id_meeting);
        $stmt->execute();
    } catch (PDOexception $e) {
        $this->logger->error($e->getMessage());
        exit('Error occured in DELETE Meeting');
    }

    $basePath = $request->getUri()->getBasePath();
    return $response->withRedirect($basePath."/meetings");
})->setName('meeting_delete');
