(defun elisp-demos--parse-org-file (file)
  (with-current-buffer (find-file-noselect file)
	(let* ((ast (org-element-parse-buffer )))
	  (org-element-map ast 'headline
		(lambda (headline)
		  (when-let* ((title (org-element-property :raw-value headline))
			          (section (car (org-element-contents headline)))
			          (children (org-element-contents section))
			          (first (pop children))
			          (src-block (if (eq (org-element-type first) 'property-drawer)
							         (pop children)
							       first))
			          (src-txt (org-element-property :value src-block))
			          (result-txt (if-let* ((result-block (pop children)))
							          (org-element-property :value result-block)
							        "")))
			(list
			 (cons "name" title)
			 (cons "demo-src" src-txt)
			 (cons "demo-result" result-txt))
			))))))

(defun elisp-demos-generate-json ()
  (interactive)
  (let* ((ret (elisp-demos--parse-org-file (expand-file-name "elisp-demos.org" elisp-demos--load-dir)))
	     (json-ret (json-encode ret))
         (out-file (expand-file-name "elisp-demos.json")))
    (with-temp-buffer
	  (insert json-ret)
	  (json-pretty-print-buffer)
	  (write-region (point-min) (point-max)
				    out-file))))
