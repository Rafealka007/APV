<?php

use \Psr\Http\Message\ServerRequestInterface as Request;
use \Psr\Http\Message\ResponseInterface as Response;

include 'location.php';

$app->get('/', function (Request $request, Response $response, $args) {
    // Render index view
    return $this->view->render($response, 'index.latte');
})->setName('index');



$app->post('/test', function (Request $request, Response $response, $args) {
    //read POST data
    $input = $request->getParsedBody();

    //log
    $this->logger->info('Your name: ' . $input['person']);

    return $response->withHeader('Location', $this->router->pathFor('index'));
})->setName('redir');


/* Zoznam vsech osob v DB */
$app->get('/persons', function (Request $request, Response $response, $args) {
	$stmt = $this->db->query('SELECT * FROM person ORDER BY first_name'); # toto vrati len DB objekt, nie vysledok!
	$tplVars['persons_list'] = $stmt->fetchall(); # [ ['id_person' => 1, 'first_name' => 'Alice' ... ], ['id_person' => 2, 'first_name' => 'Bob' ... ] . ]
	return $this->view->render($response, 'persons.latte', $tplVars);
});


$app->get('/search', function (Request $request, Response $response, $args) {
	$queryParams = $request->getQueryParams(); # [kluc => hodnota]
	if(! empty($queryParams) ) {
		$stmt = $this->db->prepare("SELECT * FROM person WHERE lower(first_name) = lower(:fname) OR lower(last_name) = lower(:lname)");
		$stmt->bindParam(':fname', $queryParams['q']);
		$stmt->bindParam(':lname', $queryParams['q']);
		$stmt->execute();
		$tplVars['persons_list'] = $stmt->fetchall();
		return $this->view->render($response, 'persons.latte', $tplVars);
	}
})->setName('search');


/* nacitanie formularu */
$app->get('/person', function (Request $request, Response $response, $args) {
	return $this->view->render($response, 'newPerson.latte');
})->setName('newPerson');

/* spracovanie formu po odoslani */
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
				$tplVars['message'] = 'Person succefully added';
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
    if (! empty($params["id_person"])){
        $stmt = $this->db->prepare("SELECT * FROM person
									LEFT JOIN location USING (id_location)
									WHERE id_person = :id_person");
        $stmt->bindValue(":id_person", $params["id_person"]);
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
    $params = $request->getQueryParams();
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
                $id_location = $stmt->fetch()["id_location"]; #{"id location" => 123}

                if($id_location){
                    #osoba má adresu
                    editLocation($this, $id_location, $formData);
                } else{
                    #osoba nemá adresu
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
$app->post('/persons/delete', function (Request $request, Response $response, $args) {
    $id_person = $request->getQueryParam('id_person');
    if (!empty($id_person)) {
        try {
            # delete from contact
            # delete from person_meeting
            # delete from relation

            $stmt = $this->db->prepare('DELETE FROM person WHERE id_person = :id_person');
            $stmt->bindValue(':id_person', $id_person);
            $stmt->execute();
        } catch (PDOexception $e) {
            $this->logger->error($e->getMessage());
            exit('error occured');
        }
    } else {
        exit('is person is missing');
    }
    $basePath = $request->getUri()->getBasePath();
    return $response->withRedirect($basePath."/persons");
})->setName('person_delete');


$app->get('/person/info', function (Request $request, Response $response, $args) {
    $stmt = $this->db->query('SELECT * FROM person');
    $tplVars['person_list'] = $stmt->fetchall();
    return $this->view->render($response, 'infoPerson.latte', $tplVars);

})->setName("infoPerson");









/*MEETINGS*/
$app->get('/meetings', function (Request $request, Response $response, $args) {
    $stmt = $this->db->query('SELECT * FROM meeting ORDER BY start'); # toto vrati len DB objekt, nie vysledok!
    $tplVars['meeting_list'] = $stmt->fetchall(); # [ ['id_person' => 1, 'first_name' => 'Alice' ... ], ['id_person' => 2, 'first_name' => 'Bob' ... ] . ]
    return $this->view->render($response, 'meetings.latte', $tplVars);
});

/* person update nacteni formulare

$app->get('/meeting/update', function (Request $request, Response $response, $args) {
    $params = $request->getQueryParams();
    if (! empty($params["id_meeting"])){
        $stmt = $this->db->prepare("SELECT * FROM meeting WHERE id_meeting = :id_meeting");
        $stmt->bindValue(":id_meeting", $params["id_meeting"]);
        $stmt->execute();
        $tplVars["formData"] = $stmt->fetch();
        if (empty($tplVars["formData"])){
            exit("person not found");
        } else {
            return $this->view->render($response, 'updateMeeting.latte', $tplVars);
        }
    }
})->setName("updateMeeting");

person update prace s formularem
$app->post("/meeting/update", function (Request $request, Response $response, $args){
    $id_person = $request->getQueryParam('id_meeting');
    $params = $request->getQueryParams();
    $formData = $request->getParsedBody();
        try {
            if( !empty($formData["street_name"]) || !empty($formData["street_number"])
                || !empty($formData["city"]) || !empty($formData["zip"])){

                $stmt = $this->db->prepare("SELECT id_location FROM person WHERE id_person = :id_person");
                $stmt->bindValue(":id_person", $id_person);
                $stmt->execute();
                $id_location = $stmt->fetch()["id_location"]; #{"id location" => 123}

                if($id_location){
                    #osoba má adresu
                    editLocation($this, $id_location, $formData);
                } else{
                    #osoba nemá adresu
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
    $tplVars["formData"] = $formData;
    $this->view->render($response, 'updatePerson.latte', $tplVars);
    $basePath = $request->getUri()->getBasePath();
    return $response->withRedirect($basePath."/persons");
});
*/

/* nacitanie formularu */
$app->get('/meeting', function (Request $request, Response $response, $args) {
    $stmt = $this->db->query('SELECT * FROM location INNER JOIN person USING (id_location)');
    $tplVars['location_list'] = $stmt->fetchall();
    return $this->view->render($response, 'newMeeting.latte', $tplVars);
})->setName('newMeeting');

/* spracovanie formu po odoslani */
$app->post('/meeting', function (Request $request, Response $response, $args) {
    $formData = $request->getParsedBody();
    $tplVars = [];
    printf($formData);
    if (empty($formData['start']) || empty($formData['description'])) {
        $tplVars['message'] = 'Please fill required fields';
    } else {
        try {
            $this->db->beginTransaction();
            $stmt = $this->db->prepare("INSERT INTO meeting (start, decsription, duration, id_location) VALUES (:start, :description, :duration, :id_location)");
            $stmt->bindValue(':start', $formData['start']);
            $stmt->bindValue(':description', $formData['description']);
            $stmt->bindValue(':duration', $formData['duration']);
            $stmt->bindValue(':id_location', $formData['id_location']);
            $stmt->execute();

            $tplVars['message'] = 'Person succefully added';
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
/*$app->get('/meeting', function (Request $request, Response $response, $args) {
    $stmt = $this->db->query('SELECT * FROM location ORDER BY city'); # toto vrati len DB objekt, nie vysledok!
    $tplVars['location_list'] = $stmt->fetchall(); # [ ['id_person' => 1, 'first_name' => 'Alice' ... ], ['id_person' => 2, 'first_name' => 'Bob' ... ] . ]
    return $this->view->render($response, 'persons.latte', $tplVars);
});*/


