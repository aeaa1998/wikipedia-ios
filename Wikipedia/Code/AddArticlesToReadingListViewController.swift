import UIKit

class ReadingListsListCollectionViewController: ReadingListsViewController {
    
    fileprivate let articles: [WMFArticle]
    
    init(with dataStore: MWKDataStore, articles: [WMFArticle]) {
        self.articles = articles
        super.init(with: dataStore)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.allowsMultipleSelection = false
    }
    
    public weak var delegate: AddArticlesToReadingListDelegate?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedReadingList = readingList(at: indexPath) else {
            return
        }
        do {
         try readingListsController.add(articles: articles, to: selectedReadingList)
            delegate?.addedArticleToReadingList?(named: selectedReadingList.name!)
        } catch let err {
            print(err)
            // do something
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

@objc public protocol AddArticlesToReadingListDelegate: NSObjectProtocol {
    func viewControllerWillBeDismissed()
    @objc optional func addedArticleToReadingList(named name: String)
}

class AddArticlesToReadingListViewController: UIViewController {
    
    fileprivate let dataStore: MWKDataStore
    fileprivate let articles: [WMFArticle]
    
    @IBOutlet weak var navigationBar: UINavigationBar?
    @IBOutlet weak var addButton: UIBarButtonItem?
    @IBOutlet weak var closeButton: UIBarButtonItem?
    
    fileprivate var readingListsListViewController: ReadingListsListCollectionViewController?
    @IBOutlet weak var containerView: UIView!
    
    fileprivate var theme: Theme
    
    init(with dataStore: MWKDataStore, articles: [WMFArticle], theme: Theme) {
        self.dataStore = dataStore
        self.articles = articles
        self.theme = theme
        super.init(nibName: "AddArticlesToReadingListViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
        delegate?.viewControllerWillBeDismissed()
    }
    
    @IBAction func addButtonPressed() {
        let createReadingListViewController = CreateReadingListViewController(theme: self.theme)
        createReadingListViewController.delegate = readingListsListViewController
        present(createReadingListViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar?.topItem?.title = String.localizedStringWithFormat(WMFLocalizedString("add-articles-to-reading-list", value:"Add %1$@ articles to reading list", comment:"Title for the view in charge of adding articles to a reading list - %1$@ is replaced with the number of articles to add"), "\(articles.count)")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        
        readingListsListViewController = ReadingListsListCollectionViewController.init(with: dataStore, articles: articles)
        guard let readingListsListViewController = readingListsListViewController else {
            return
        }
        addChildViewController(readingListsListViewController)
        readingListsListViewController.view.frame = containerView.bounds
        readingListsListViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(readingListsListViewController.view)
        readingListsListViewController.didMove(toParentViewController: self)
        readingListsListViewController.delegate = self
        apply(theme: theme)
    }
    
    public weak var delegate: AddArticlesToReadingListDelegate?

}

extension AddArticlesToReadingListViewController: AddArticlesToReadingListDelegate {
    func viewControllerWillBeDismissed() {
        delegate?.viewControllerWillBeDismissed()
    }
    
    func addedArticleToReadingList(named name: String) {
        delegate?.addedArticleToReadingList?(named: name)
    }
}

extension AddArticlesToReadingListViewController: Themeable {
    func apply(theme: Theme) {
        self.theme = theme
        guard viewIfLoaded != nil else {
            return
        }
        
        navigationBar?.barTintColor = theme.colors.chromeBackground
        navigationBar?.tintColor = theme.colors.chromeText
        navigationBar?.titleTextAttributes = theme.navigationBarTitleTextAttributes
        view.tintColor = theme.colors.link
        navigationBar?.setBackgroundImage(theme.navigationBarBackgroundImage, for: .default)
        view.backgroundColor = theme.colors.chromeBackground
        readingListsListViewController?.apply(theme: theme)
    }
}
