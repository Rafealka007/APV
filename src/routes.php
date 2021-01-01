<?php

use \Psr\Http\Message\ServerRequestInterface as Request;
use \Psr\Http\Message\ResponseInterface as Response;

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
			$stmt = $this->db->prepare("INSERT INTO person (nickname, first_name, last_name, id_location, birth_day, height, gender) VALUES (:nickname, :first_name, :last_name, :id_location, :birth_day, :height, :gender)");	
				$stmt->bindValue(':nickname', $formData['nickname']);
				$stmt->bindValue(':first_name', $formData['first_name']);
				$stmt->bindValue(':last_name', $formData['last_name']);
				$stmt->bindValue(':id_location', empty($formData['id_location']) ? null : $formData['id_location']);
				$stmt->bindValue(':gender', empty($formData['gender']) ? null : $formData['gender'] ) ;
				$stmt->bindValue(':birth_day', empty($formData['birth_day']) ? null : $formData['birth_day']);
				$stmt->bindValue(':height', empty($formData['height']) ? null : $formData['height']);
				$stmt->execute();
				$tplVars['message'] = 'Person succefully added';
		} catch (PDOexception $e) {
			$tplVars['message'] = 'Error occured, sorry jako';
			$this->logger->error($e->getMessage());
		}
	}

	return $this->view->render($response, 'newPerson.latte', $tplVars);
});